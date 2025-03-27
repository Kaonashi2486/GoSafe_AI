"use client";

import SideScroll from "@/app/components/SideScroll";
import Link from "next/link";
import { useState } from "react";

export default function MapRouting() {
  const [location, setLocation] = useState("");
  const [crimeRisk, setCrimeRisk] = useState(false);
  const [weatherRisk, setWeatherRisk] = useState(false);

  return (
    <main className="bg-gray-900 text-white min-h-screen flex flex-col items-center py-6">
      <SideScroll />

      {/* Search Bar */}
      <div className="w-[90%] max-w-3xl flex items-center space-x-3 mb-6">
        <input
          type="text"
          placeholder="Enter location..."
          className="w-full p-3 bg-gray-800 text-white rounded-lg outline-none"
          value={location}
          onChange={(e) => setLocation(e.target.value)}
        />
        <button className="px-4 py-3 bg-blue-500 hover:bg-blue-600 rounded-lg">
          Search
        </button>
      </div>

      {/* Map Section */}
      <div className="w-full h-[70vh] bg-gray-700 flex justify-center items-center">
        <h2 className="text-2xl text-blue-300">Live Map Placeholder</h2>
      </div>

      {/* Checkbox Section */}
      <div className="mt-6 flex space-x-6">
        <label className="flex items-center space-x-2">
          <input
            type="checkbox"
            checked={crimeRisk}
            onChange={() => setCrimeRisk(!crimeRisk)}
            className="w-5 h-5 accent-red-500"
          />
          <span className="text-2xl ">Crime Risk</span>
        </label>

        <label className="flex items-center space-x-2">
          <input
            type="checkbox"
            checked={weatherRisk}
            onChange={() => setWeatherRisk(!weatherRisk)}
            className="w-5 h-5 accent-blue-500"
          />
          <span className="text-2xl">Weather Risk</span>
        </label>
      </div>
    </main>
  );
}

