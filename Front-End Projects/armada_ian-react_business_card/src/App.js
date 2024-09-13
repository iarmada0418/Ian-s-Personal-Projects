import Photo from './Photo';
import NameDesc from './NameDesc';
import Buttons from './Buttons';
import About from './About';
import Footer from './Footer';
import './App.css';

function App() {
  return (
    <div className="App">
      <Photo/>
      <NameDesc/>
      <Buttons/>
      <About/>
      <Footer/>
    </div>
  );
}

export default App;
