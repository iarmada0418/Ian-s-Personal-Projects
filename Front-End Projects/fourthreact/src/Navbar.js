import logo from './logo.svg';

export default function Navbar(){
    return(
        <nav>
            <img src={logo} className="logo"/>
            <h3 className="nav--logo_text">React Facts</h3>
            <h4 className="nav--logo_title">React Course - Project 1</h4>
        </nav>
    );
}