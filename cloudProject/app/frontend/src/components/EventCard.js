import React from "react";
import { useNavigate } from "react-router-dom";

const EventCard = ({ event }) => {
  const navigate = useNavigate();

  const handleBuyClick = () => {
    navigate(`/checkout/${event.id}`);
  };

  return (
    <div className="event-card">
      <img src={event.image} alt={event.name} className="event-image" />
      <h3>{event.name}</h3>
      <p>{event.date}</p>
      <button onClick={handleBuyClick}>Comprar Boletos</button>
    </div>
  );
};

export default EventCard;