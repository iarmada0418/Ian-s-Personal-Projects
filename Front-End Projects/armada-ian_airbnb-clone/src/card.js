import star from './images/Star 1.png'

export default function Card(props){
    let badgeText
    if(props.openSpots === 0){
        badgeText = "SOLD OUT"
    } else if(props.location === "Online") {
        badgeText = "ONLINE"
    }

    return(
        <div className="card">
            {badgeText && <div className="card--badge">{badgeText}</div>}
            <img src={`../images/${props.coverImg}`} alt="" className="card--img"/>
            <div className="card--stats">
                <img src= {star} alt="" className="star"/>
                <span>{props.stats.rating}</span>
                <span className="card--gray">({props.stats.reviewCount}) · </span>
                <span className="card--gray">{props.location}</span>
            </div>
            <p className="card--title">{props.title}</p>
            <p><span className="card--bold">From ${props.price}</span> / person</p>
            
        </div>
    );
}