import React from 'react';
import * as ReactDOM from 'react-dom';

function Header(){
    return(
            <header>
                <nav className="nav">
                    <img src="./react.png" className="logo"/>
                    <ul className="nav-items">
                        <li>Pricing</li>
                        <li>About</li>
                        <li>Contact</li>
                    </ul>
                </nav>
                
            </header>
    );
}

function MainContent(){
    return(
        <div>
            <h1>
                Reasons I'm excited to learn React
            </h1>
            <ol>
                <li>It's a popular library!</li>
                <li>More likely to get a job as a devloper if I know React!</li>
            </ol>
        </div>
    );
}

function Footer(){
    return(
            <footer>
                <small>© Armada development. All rights reserved.</small>
            </footer>
    );
}

function Page(){
    return (
        <div>
            <Header/>
            <MainContent/>
            <Footer/>
        </div>
    );
}

ReactDOM.render(<Page/>, document.getElementById("root"));