import React, { useState } from 'react';
import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import './App.css';

import moonIcon from './icons/moon.svg';
import sunIcon from './icons/sun.png';
import downloadIcon from './icons/download.png';

const App = () => {
  const [darkMode, setDarkMode] = useState(false);

  const screenshots = Array.from({ length: 14 }, (_, i) => `/images/screen${i + 1}.jpg`);

  const sliderSettings = {
    dots: true,
    infinite: true,
    speed: 500,
    slidesToShow: 3,
    slidesToScroll: 1,
    autoplay: true,
    autoplaySpeed: 3000,
    arrows: true,
    prevArrow: <CustomPrevArrow />,
    nextArrow: <CustomNextArrow />
  };

  const handleDownload = () => {
    const link = document.createElement("a");
    link.href = "/downloads/drop.apk";
    link.setAttribute("download", "drop.apk");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className={`container ${darkMode ? 'dark' : 'light'}`}>
      <header>
        <h1>DROp - Dynamic Route Optimization in Last-Mile Delivery</h1>
        <button className="icon-button" onClick={() => setDarkMode(!darkMode)}>
          <img src={darkMode ? sunIcon : moonIcon} alt="Theme Toggle" className="icon" />
        </button>
      </header>

      <section className="about">
        <h2>About</h2>
        <p><b>DROp</b> is a dynamic route optimization tool designed to help delivery agents improve efficiency and reduce delays. Utilizing a <b>Flutter</b> frontend and a <b>Node.js</b> backend, the mobile application </p>
        <a href="http://localhost:3000/downloads/drop.apk" className="download-btn" onClick={(e) => { e.preventDefault(); handleDownload(); }}>
          <img src={downloadIcon} alt="Download" className="download-icon" />
          Download
        </a>

      </section>

      <section className="screenshots">
        <h2>Screenshots</h2>
        <Slider {...sliderSettings}>
          {screenshots.map((src, index) => (
            <div key={index}>
              <img src={src} alt={`Screenshot ${index + 1}`} />
            </div>
          ))}
        </Slider>
      </section>

      <section className="contact">
        <h2>Contact</h2>
        <b>Team Pr0xy</b> <br />
        <b>Email: anexantony2783@gmail.com</b><br />
        <b>Phone: +91 7034456811</b><br />
        <a href="https://github.com/AnexAntony278/DROp">Github</a>
      </section>
    </div>
  );
};

const CustomPrevArrow = (props) => (
  <div className="custom-arrow custom-prev" onClick={props.onClick}>
    ❮
  </div>
);

const CustomNextArrow = (props) => (
  <div className="custom-arrow custom-next" onClick={props.onClick}>
    ❯
  </div>
);

export default App;
