"use client";
import SlideIn from "@/app/components/SlideIN";
import Link from "next/link";
import { useState } from "react";

export default function Location() {
  const [location, setLocation] = useState("");

  return (
    <SlideIn direction="left">
    <main className="bg-gray-900 text-white min-h-screen flex flex-col items-center py-6">
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

      {/* Features Section */}
      <div className="grid grid-cols-2 gap-6 mt-6 w-[90%] max-w-4xl">
        <Link href="/pages/maprouting">
          <button className="w-full py-4 bg-blue-500 hover:bg-blue-600 rounded-lg text-lg">
            Safe Routing
          </button>
        </Link>
        <Link href="/feature2">
          <button className="w-full py-4 bg-blue-500 hover:bg-blue-600 rounded-lg text-lg">
            Crowded Safety
          </button>
        </Link>
      </div>
    </main>
    </SlideIn>
  );
}
