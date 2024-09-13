import airbnb from './images/airbnb 1.png'

export default function Navbar(){
    return(
        <div className="navbar">
            <img src={airbnb} alt="" className="airbnb-logo"/>
        </div>
    );
}