import React, { useState } from 'react';
import { BrowserRouter as Router, Route, Routes, Link } from 'react-router-dom';
import VotingGrid from './components/VotingGrid';
import ResultsPage from './components/ResultsPage';
import './App.css';

function App() {
  return (
    <Router>
      <div className="app-container">
        <header>
          <nav>
            <Link to="/" className="nav-link">Votar</Link>
            <Link to="/resultados" className="nav-link">Resultados</Link>
          </nav>
        </header>
        <main>
          <Routes>
            <Route path="/" element={<VotingGrid />} />
            <Route path="/resultados" element={<ResultsPage />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;