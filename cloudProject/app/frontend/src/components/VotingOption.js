import React from 'react';
import './VotingOption.css';

function VotingOption({ option, onClick }) {
  // Generación de SVG aleatorio simple
  const getSvgPattern = () => {
    const patterns = [
      <circle cx="50" cy="50" r="30" fill="#ffffff" opacity="0.6" />,
      <rect x="20" y="20" width="60" height="60" rx="10" fill="#ffffff" opacity="0.5" />,
      <polygon points="50,20 80,50 50,80 20,50" fill="#ffffff" opacity="0.6" />,
      <path d="M25,50 a25,25 0 1,1 50,0 a25,25 0 1,1 -50,0" fill="#ffffff" opacity="0.5" />
    ];
    
    const randomIndex = Math.floor(option.id % patterns.length);
    return patterns[randomIndex];
  };

  return (
    <div className="voting-option" onClick={onClick}>
      <div className="option-image" style={{ backgroundColor: option.svgColor }}>
        <svg viewBox="0 0 100 100">
          {getSvgPattern()}
        </svg>
      </div>
      <h3>{option.name}</h3>
    </div>
  );
}

export default VotingOption;