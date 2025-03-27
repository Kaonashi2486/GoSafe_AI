const Footer = () => {
    return (
      <footer className="bg-gray-900 text-white text-center py-6">
        <p className="text-blue-200">&copy; {new Date().getFullYear()} GoSafe AI. All rights reserved.</p>
        <div className="flex justify-center space-x-6 mt-4">
          <a href="#" className="text-blue-300 hover:text-blue-400">Privacy Policy</a>
          <a href="#" className="text-blue-300 hover:text-blue-400">Terms of Use</a>
          <a href="#" className="text-blue-300 hover:text-blue-400">Contact</a>
        </div>
      </footer>
    );
  };
  
  export default Footer;
  