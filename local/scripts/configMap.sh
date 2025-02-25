#!/bin/bash

# Define variables manualmente (ya que terraform output no funciona)
CLUSTER_NAME="tfm-cluster"  # REEMPLAZAR con el nombre real de tu cluster
REGION="us-east-1"                  # REEMPLAZAR con tu región de AWS
AWS_PROFILE="tfm"             # Perfil AWS a utilizar

# Primero actualiza tu kubeconfig
echo "Actualizando kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION --profile $AWS_PROFILE

# Verifica si la actualización funcionó
if [ $? -ne 0 ]; then
  echo "Error actualizando kubeconfig. Verificando configuración de AWS..."
  aws sts get-caller-identity --profile $AWS_PROFILE
  echo "Verificando si el cluster existe..."
  aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --profile $AWS_PROFILE
  exit 1
fi

# Obtén el ARN del usuario/rol actual
CURRENT_USER_ARN=$(aws sts get-caller-identity --query "Arn" --output text --profile $AWS_PROFILE)
echo "Usuario actual: $CURRENT_USER_ARN"

# Obtén el nodegroup para extraer el role ARN
NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --region $REGION --query 'nodegroups[0]' --output text --profile $AWS_PROFILE)
if [ -z "$NODE_GROUPS" ]; then
  echo "No se encontraron nodegroups en el cluster $CLUSTER_NAME"
  exit 1
fi

NODE_GROUP_INFO=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_GROUPS --region $REGION --profile $AWS_PROFILE)
NODE_ROLE_ARN=$(echo $NODE_GROUP_INFO | jq -r '.nodegroup.nodeRole')
echo "Role ARN del nodegroup: $NODE_ROLE_ARN"

# Crea un archivo yaml temporal limpio
cat > aws-auth.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${NODE_ROLE_ARN}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${CURRENT_USER_ARN}
      username: admin
      groups:
        - system:masters
EOF

echo "Contenido del ConfigMap aws-auth:"
cat aws-auth.yaml

# Aplica el ConfigMap
echo "Aplicando ConfigMap aws-auth..."
kubectl apply -f aws-auth.yaml

# Espera unos segundos para que los cambios se propaguen
echo "Esperando que los cambios se propaguen..."
sleep 10

# Verifica el acceso
echo "Verificando acceso al clúster..."
kubectl get nodes