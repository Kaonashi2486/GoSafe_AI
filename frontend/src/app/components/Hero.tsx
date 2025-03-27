"use client";
import Link from "next/link";
import BackgroundVideo from "./ui/BackgroundVideo";

const Hero: React.FC = () => {
  return (
    <div className="relative w-full h-screen overflow-hidden flex items-center justify-center text-center text-white">
      
      {/* Video Background */}
      <BackgroundVideo />

      {/* Gradient Overlay for better readability */}
      <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-black/30 to-gray-900/80"></div>

      {/* Hero Content */}
      <div className="absolute z-10 px-6">
        <h1 className="text-5xl md:text-7xl font-bold text-blue-300">
          Welcome to GoSafe AI
        </h1>
        <p className="text-lg md:text-2xl mt-4 text-blue-200">
          Your smart travel safety companion, providing real-time risk assessment and alerts.
        </p>
        <div className="mt-6 flex space-x-4 justify-center">
          <Link
            href="#about"
            className="px-6 py-3 bg-blue-500 hover:bg-blue-600 rounded-lg text-white text-lg"
          >
            Learn More
          </Link>
          <Link
            href="/pages/location"
            className="px-6 py-3 border border-white hover:bg-white rounded-lg text-blue-500 text-lg"
          >
            Get Started
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Hero;
