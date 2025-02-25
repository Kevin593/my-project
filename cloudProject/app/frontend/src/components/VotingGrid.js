import React, { useState, useEffect } from 'react';
import VotingOption from './VotingOption';
import Modal from './Modal';
import './VotingGrid.css';

function VotingGrid() {
  const [options, setOptions] = useState([]);
  const [selectedOption, setSelectedOption] = useState(null);
  const [showModal, setShowModal] = useState(false);

  useEffect(() => {
    // Simulación de carga de opciones desde API
    const apiUrl = process.env.REACT_APP_API_URL;
    fetch(`${apiUrl}/options`)
      .then((response) => console.log(response.json()))
      .then((data) => setOptions(data))
      .catch((error) => console.error("Error fetching results:", error));
    /*const mockOptions = [
      { id: 1, name: 'Opción 1', svgColor: '#a8d8f0' },
      { id: 2, name: 'Opción 2', svgColor: '#84bce6' },
      { id: 3, name: 'Opción 3', svgColor: '#6da5d9' },
      { id: 4, name: 'Opción 4', svgColor: '#5a96cc' },
      { id: 5, name: 'Opción 5', svgColor: '#4a88bf' },
      { id: 6, name: 'Opción 6', svgColor: '#3a7ab2' },
      { id: 7, name: 'Opción 7', svgColor: '#2b6da5' },
      { id: 8, name: 'Opción 8', svgColor: '#1c5f98' },
    ];*/
  }, []);

  const handleOptionClick = (option) => {
    setSelectedOption(option);
    setShowModal(true);
  };

  const handleVote = async () => {
    try {
      const apiUrl = process.env.REACT_APP_API_URL;
      const response = await fetch(`${apiUrl}/vote`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ optionId: selectedOption.id }), 
      });
  
      const data = await response.json(); 
      alert(`Voto registrado: ${selectedOption.name}!`);
  
      setShowModal(false);
    } catch (error) {
      console.error("Error al registrar voto:", error);
    }
  };

  return (
    <div className="voting-container">
      <h1>Selecciona una opción para votar</h1>
      <div className="voting-grid">
        {options.map(option => (
          <VotingOption
            key={option.id}
            option={option}
            onClick={() => handleOptionClick(option)}
          />
        ))}
      </div>

      {showModal && (
        <Modal onClose={() => setShowModal(false)}>
          <div className="vote-confirmation">
            <h2>Confirmar voto</h2>
            <div className="option-preview">
              <div className="option-image" style={{ backgroundColor: selectedOption.svgColor }}>
                <svg viewBox="0 0 100 100">
                  <path d="M25,50 a25,25 0 1,1 50,0 a25,25 0 1,1 -50,0" fill="#ffffff" opacity="0.6" />
                  <path d="M35,50 L45,60 L65,40" stroke="#ffffff" strokeWidth="5" fill="none" />
                </svg>
              </div>
              <h3>{selectedOption.name}</h3>
            </div>
            <button className="vote-button" onClick={handleVote}>
              Confirmar voto
            </button>
          </div>
        </Modal>
      )}
    </div>
  );
}

export default VotingGrid;