import facebook from './Facebook Icon.png'
import instagram from './Instagram Icon.png'
import github from './GitHub Icon.png'
import twitter from './Twitter Icon.png'

export default function Footer(){
    return(
        <div className="footer">
            <img src={facebook} className="footer-facebook"/>
            <img src={instagram} className="footer-instagram"/>
            <img src={github} className="footer-github"/>
            <img src={twitter} className="footer-twitter"/>
        </div>
    );
}