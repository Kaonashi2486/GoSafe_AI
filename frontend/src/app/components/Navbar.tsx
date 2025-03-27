"use client";
import Link from "next/link";
import { useState } from "react";
import { FiUser } from "react-icons/fi";

const Navbar = () => {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <nav className="fixed top-4 left-1/2 transform -translate-x-1/2 bg-gray-800 text-white rounded-2xl shadow-lg py-3 px-6 flex items-center justify-between w-[90%] max-w-3xl backdrop-blur-md z-50">
      {/* Logo */}
      <Link href="/">
        <h1 className="text-xl font-bold text-blue-300 cursor-pointer">GoSafe AI</h1>
      </Link>

      {/* Nav Links */}
      <div className="hidden md:flex space-x-6">
        <Link href="#about" className="text-blue-300 hover:text-blue-400">
          About
        </Link>
        <Link href="#feature" className="text-blue-300 hover:text-blue-400">
          Features
        </Link>
        <Link href="#contact" className="text-blue-300 hover:text-blue-400">
          Contact
        </Link>
      </div>

      {/* Login/Signup */}
      <div className="flex items-center space-x-4">
        <Link href="/pages/admin">
          <FiUser className="text-blue-300 hover:text-blue-400 text-xl cursor-pointer" />
        </Link>
      </div>

      {/* Mobile Menu Button */}
      <button
        className="md:hidden text-blue-300 text-2xl"
        onClick={() => setMenuOpen(!menuOpen)}
      >
        ☰
      </button>

      {/* Mobile Menu */}
      {menuOpen && (
        <div className="absolute top-14 right-0 w-48 bg-gray-900 rounded-lg shadow-lg p-4 flex flex-col space-y-3 md:hidden">
          <Link href="#about" className="text-blue-300 hover:text-blue-400">
            About
          </Link>
          <Link href="#features" className="text-blue-300 hover:text-blue-400">
            Features
          </Link>
          <Link href="#contact" className="text-blue-300 hover:text-blue-400">
            Contact
          </Link>
          <Link href="/pages/admin" className="text-blue-300 hover:text-blue-400">
            Login
          </Link>
        </div>
      )}
    </nav>
  );
};

export default Navbar;
