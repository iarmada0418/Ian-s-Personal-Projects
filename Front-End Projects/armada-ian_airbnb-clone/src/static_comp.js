import photogrid from './images/Group 77.png'
export default function Hero(){
    return(
        <section className="static">
            <img src={photogrid} alt="" className="static--photo"/>
            <h1 className="static--title">Online Experiences</h1>
            <p1 className="static--desc">Join unique interactive activities led by one-of-a-kind hosts—all without leaving home.</p1>
        </section>
    );
}