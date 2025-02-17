import React from "react";
import EventCard from "../components/EventCard";

const events = [
  {
    id: 1,
    name: "Concierto de Coldplay",
    date: "15 de Noviembre, 2023",
    image: "https://via.placeholder.com/300x200?text=Coldplay",
  },
  {
    id: 2,
    name: "Recital de Taylor Swift",
    date: "20 de Diciembre, 2023",
    image: "https://via.placeholder.com/300x200?text=Taylor+Swift",
  },
  {
    id: 3,
    name: "Obra de Teatro: Hamlet",
    date: "10 de Enero, 2024",
    image: "https://via.placeholder.com/300x200?text=Hamlet",
  },
];

const Home = () => {
  return (
    <div className="home">
      <h1>Eventos Disponibles</h1>
      <div className="event-list">
        {events.map((event) => (
          <EventCard key={event.id} event={event} />
        ))}
      </div>
    </div>
  );
};

export default Home;