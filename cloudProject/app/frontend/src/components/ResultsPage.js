import React, { useState, useEffect } from 'react';
import { Bar } from 'react-chartjs-2';
import { Pie } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from 'chart.js';
import './ResultsPage.css';

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
);

function ResultsPage() {
  const [votingData, setVotingData] = useState({
    options: [],
    totalVotes: 0
  });
  
  useEffect(() => {
    // Función para cargar resultados iniciales
    const fetchInitialData = async () => {
      try {
        let result;
        let listOptions = [];
        // Simulación de datos desde API
        const apiUrl = process.env.REACT_APP_API_URL;
        await fetch(`${apiUrl}/results`)
        .then((response) => response.json())
        .then((data) => {
          console.log(data);
          const transformedData = data.map((option, index) => ({
            id: option.id, 
            name: option.name,
            votes: option.votes,
            svgColor: option.svgColor
          }));
          // Calcular el total de votos
          const totalVotes = transformedData.reduce((sum, option) => sum + option.votes, 0);
          // Formato final
          result = {
            options: transformedData,
            totalVotes
          };
        })
        .catch((error) => console.error("Error fetching results:", error));
        setVotingData(result);
      } catch (error) {
        console.error('Error al cargar resultados:', error);
      }
    };

    fetchInitialData();

    // Configurar actualización en tiempo real (websocket simulado)
    const intervalId = setInterval(async () => {
      try {
        const apiUrl = process.env.REACT_APP_API_URL;
        const response = await fetch(`${apiUrl}/results`);
        const data = await response.json();
  
        console.log(data);
  
        const transformedData = data.map((option) => ({
          id: option.id,
          name: option.name,
          votes: option.votes,
          svgColor: option.svgColor,
        }));
  
        const totalVotes = transformedData.reduce((sum, option) => sum + option.votes, 0);
  
        setVotingData({ options: transformedData, totalVotes }); // ✅ Actualiza el estado correctamente
      } catch (error) {
        console.error("Error fetching results:", error);
      }
    }, 3000);

    return () => clearInterval(intervalId);
  }, []);

  // Preparar datos para gráfico de barras
  const barChartData = {
    labels: votingData.options.map(opt => opt.name),
    datasets: [
      {
        label: 'Votos',
        data: votingData.options.map(opt => opt.votes),
        backgroundColor: votingData.options.map(opt => opt.svgColor),
        borderColor: votingData.options.map(opt => '#000000'),
        borderWidth: 1,
      },
    ],
  };

  // Preparar datos para gráfico circular
  const pieChartData = {
    labels: votingData.options.map(opt => opt.name),
    datasets: [
      {
        data: votingData.options.map(opt => opt.votes),
        backgroundColor: votingData.options.map(opt => opt.svgColor),
        borderColor: '#ffffff',
        borderWidth: 1,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top',
      },
      title: {
        display: true,
        text: 'Distribución de votos',
      },
    },
  };

  return (
    <div className="results-container">
      <h1>Resultados en tiempo real</h1>
      
      <div className="results-table-container">
        <table className="results-table">
          <thead>
            <tr>
              <th>Imagen</th>
              <th>Opción</th>
              <th>Votos</th>
            </tr>
          </thead>
          <tbody>
            {votingData.options.map(option => (
              <tr key={option.id}>
                <td>
                  <div className="result-image" style={{ backgroundColor: option.svgColor }}>
                    <svg viewBox="0 0 40 40">
                      <circle cx="20" cy="20" r="12" fill="#ffffff" opacity="0.6" />
                    </svg>
                  </div>
                </td>
                <td>{option.name}</td>
                <td>{option.votes}</td>
              </tr>
            ))}
            <tr className="total-row">
              <td colSpan="2">Total de votos</td>
              <td>{votingData.totalVotes}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className="charts-container">
        <div className="chart-box">
          <h2>Gráfico de barras</h2>
          <Bar data={barChartData} options={chartOptions} />
        </div>
        
        <div className="chart-box">
          <h2>Gráfico circular</h2>
          <Pie data={pieChartData} options={chartOptions} />
        </div>
      </div>
    </div>
  );
}

export default ResultsPage;