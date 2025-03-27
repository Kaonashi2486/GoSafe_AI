const About = () => {
    return (
      <section id="about" className="py-16 bg-gray-900 text-white text-center">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-4xl font-bold text-blue-300">About GoSafe AI</h2>
          <p className="text-lg mt-4 text-blue-200">
            GoSafe AI is an advanced travel safety platform that provides **real-time safety updates**, 
            **risk assessments**, and **intelligent travel alerts** based on AI-powered analysis of various data sources.
          </p>
          <div className="mt-8 grid md:grid-cols-3 gap-8">
            <div className="p-6 bg-gray-800 rounded-lg">
              <h3 className="text-xl font-semibold text-blue-300">Live Safety Alerts</h3>
              <p className="text-blue-200 mt-2">Receive real-time updates on potential risks in your destination.</p>
            </div>
            <div className="p-6 bg-gray-800 rounded-lg">
              <h3 className="text-xl font-semibold text-blue-300">AI-Powered Insights</h3>
              <p className="text-blue-200 mt-2">Leverage AI-driven data to plan safer journeys.</p>
            </div>
            <div className="p-6 bg-gray-800 rounded-lg">
              <h3 className="text-xl font-semibold text-blue-300">Global Coverage</h3>
              <p className="text-blue-200 mt-2">Access safety insights from around the world.</p>
            </div>
          </div>
        </div>
      </section>
    );
  };
  
  export default About;
  