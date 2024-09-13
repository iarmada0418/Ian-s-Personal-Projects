import React, { useEffect, useRef } from 'react';
import './App.css';
import Card from './card';
import Navbar from './navbar';
import Static from './static_comp';
import data from './data';

function App() {
  const cardsContainerRef = useRef(null);

  useEffect(() => {
    const cardsContainer = cardsContainerRef.current;

    const checkOverflow = () => {
      if (cardsContainer.scrollWidth > cardsContainer.clientWidth) {
        cardsContainer.style.justifyContent = 'flex-start';
      } else {
        cardsContainer.style.justifyContent = 'center';
      }
    };

    checkOverflow();

    window.addEventListener('resize', checkOverflow);

    return () => {
      window.removeEventListener('resize', checkOverflow);
    };
  }, []);

  const cards = data.map(item => (
    <Card
      key={item.id}
      {...item}
    />
  ));

  return (
    <div className="App">
      <header className="App-header">
        <Navbar />
        <Static />
        <div className="cards-container" ref={cardsContainerRef}>
          {cards}
        </div>
      </header>
    </div>
  );
}

export default App;
