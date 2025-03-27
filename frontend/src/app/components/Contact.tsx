const Contact = () => {
    return (
      <section id="contact" className="py-16 bg-gray-900 text-white text-center">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-4xl font-bold text-blue-300">Get in Touch</h2>
          <p className="text-lg mt-4 text-blue-200">Have questions? Contact us now.</p>
          <form className="mt-6">
            <input
              type="email"
              placeholder="Enter your email"
              className="w-full max-w-md p-3 rounded bg-gray-800 text-white border border-gray-600 focus:outline-none"
            />
            <button className="mt-4 px-6 py-3 bg-blue-500 hover:bg-blue-600 rounded text-white">
              Send Message
            </button>
          </form>
        </div>
      </section>
    );
  };
  
  export default Contact;
  