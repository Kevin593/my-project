import React, { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";

const Checkout = () => {
  const { eventId } = useParams();
  const navigate = useNavigate();
  const [cardNumber, setCardNumber] = useState("");
  const [expiry, setExpiry] = useState("");
  const [cvv, setCvv] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    alert("¡Compra exitosa! Gracias por tu compra.");
    navigate("/");
  };

  return (
    <div className="checkout">
      <h1>Finalizar Compra</h1>
      <form onSubmit={handleSubmit}>
        <label>
          Número de Tarjeta:
          <input
            type="text"
            value={cardNumber}
            onChange={(e) => setCardNumber(e.target.value)}
            required
          />
        </label>
        <label>
          Fecha de Expiración:
          <input
            type="text"
            value={expiry}
            onChange={(e) => setExpiry(e.target.value)}
            required
          />
        </label>
        <label>
          CVV:
          <input
            type="text"
            value={cvv}
            onChange={(e) => setCvv(e.target.value)}
            required
          />
        </label>
        <button type="submit">Pagar</button>
      </form>
    </div>
  );
};

export default Checkout;