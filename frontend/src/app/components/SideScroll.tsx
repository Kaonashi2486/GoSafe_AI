import { useState } from "react";
import Link from "next/link";
import { FiHome, FiFileText, FiSettings, FiMenu, FiX } from "react-icons/fi";

const SideScroll = () => {
  const [isOpen, setIsOpen] = useState<boolean>(false);

  return (
    <div className="flex">
      {/* Sidebar Container */}
      <div
        className={`fixed top-0 left-0 h-full bg-gray-900 text-white shadow-lg transition-transform duration-300 ${
          isOpen ? "w-64" : "w-16"
        }`}
      >
        <div className="flex items-center justify-between p-4">
          <h2 className={`${isOpen ? "block" : "hidden"} text-lg font-bold`}>GoSafe AI</h2>
          <button onClick={() => setIsOpen(!isOpen)} className="text-white">
            {isOpen ? <FiX size={24} /> : <FiMenu size={24} />}
          </button>
        </div>

        {/* Sidebar Links */}
        <nav className="mt-6">
          <Link href="/">
            <div className="flex items-center p-3 hover:bg-gray-700 cursor-pointer">
              <FiHome size={20} />
              <span className={`ml-4 ${isOpen ? "block" : "hidden"}`}>Home</span>
            </div>
          </Link>

          <Link href="/pages/maprouting">
            <div className="flex items-center p-3 hover:bg-gray-700 cursor-pointer">
              <FiFileText size={20} />
              <span className={`ml-4 ${isOpen ? "block" : "hidden"}`}>MapRouting</span>
            </div>
          </Link>

          <Link href="/pages/location">
            <div className="flex items-center p-3 hover:bg-gray-700 cursor-pointer">
              <FiSettings size={20} />
              <span className={`ml-4 ${isOpen ? "block" : "hidden"}`}>CrowdedSafety</span>
            </div>
          </Link>
        </nav>
      </div>
{/* 
      Main Content
      <div id="admin" className={`flex-1 p-6 transition-margin duration-300 ${isOpen ? "ml-64" : "ml-16"}`}>
        <h1 className="text-2xl font-bold text-blue-500">Admin Dashboard</h1>
        <p className="text-gray-400 mt-2">Welcome to the GoSafe AI admin panel.</p>
      </div> */}
    </div>
  );
};

export default SideScroll;
