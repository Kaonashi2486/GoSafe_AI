"use client";
const Features = () => {
    return (
      <section id="feature" className="py-16 bg-gray-900 text-white text-center">
        <div className="max-w-5xl mx-auto grid md:grid-cols-3 gap-8">
          {[
                { title: "Real-Time Alerts", description: "Stay informed with live crime, weather, and incident updates." },
                { title: "AI-Powered Route Safety", description: "Get travel routes scored based on historical and real-time data." },
                { title: "Crowdsourced Reports", description: "Verified traveler reports ensure credible safety insights." },
                { title: "Predictive Risk Forecasting", description: "AI predicts potential risks along your planned routes." },
                { title: "Emergency Assistance", description: "Instantly connect to local emergency services when needed." },
                { title: "Privacy & Security", description: "End-to-end encryption and blockchain verification protect your data." },
              
          ].map((feature, index) => (
            <div key={index} className="relative p-6 rounded-lg bg-secondary text-white overflow-hidden group">
              {/* Moving Border Animation */}
              <div className="absolute inset-0 border-2 border-transparent rounded-lg animate-corner-border"></div>
  
              <h3 className="text-xl font-semibold text-white relative z-10">{feature.title}</h3>
              <p className="text-white mt-2 relative z-10">{feature.description}</p>
            </div>
          ))}
        </div>
  
        {/* Tailwind Animation */}
        <style jsx>{`
          @keyframes cornerMove {
            0% {
              border-top: 2px solid white;
              border-left: 2px solid white;
            }
            25% {
              border-top: 2px solid transparent;
              border-right: 2px solid white;
            }
            50% {
              border-right: 2px solid transparent;
              border-bottom: 2px solid white;
            }
            75% {
              border-bottom: 2px solid transparent;
              border-left: 2px solid white;
            }
            100% {
              border-left: 2px solid transparent;
              border-top: 2px solid white;
            }
          }
  
          .animate-corner-border {
            animation: cornerMove 3s infinite linear;
          }
        `}</style>
      </section>
    );
  };
  
  export default Features;
  