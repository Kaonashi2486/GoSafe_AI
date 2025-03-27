"use client";
import Link from "next/link";
import React, { useState } from "react";
import SlideIn from "@/app/components/SlideIn";

export default function Signup() {
  const [isChecked, setIsChecked] = useState(false);

  return (
    <div
      className="h-screen bg-cover bg-center flex justify-center items-center relative"
      style={{ backgroundImage: "url('/login_bg.png')" }} // Page Background Image
    >
      {/* Signup Box */}
      <SlideIn direction="left">
        <div className="relative z-10 bg-gray-800 bg-opacity-90 p-8 rounded-lg shadow-lg w-96">
          <h2 className="text-2xl font-bold text-blue-300 mb-4">
            Join GoSafe AI – Travel Smarter & Safer
          </h2>

          <input
            type="text"
            placeholder="Username"
            className="w-full p-2 mb-3 bg-gray-700 text-white rounded"
          />
          <input
            type="email"
            placeholder="Email"
            className="w-full p-2 mb-3 bg-gray-700 text-white rounded"
          />
          <input
            type="password"
            placeholder="Password"
            className="w-full p-2 mb-3 bg-gray-700 text-white rounded"
          />

          {/* Terms & Conditions Checkbox */}
          <div className="flex items-center mb-4">
            <input
              type="checkbox"
              id="terms"
              checked={isChecked}
              onChange={() => setIsChecked(!isChecked)}
              className="mr-2 accent-blue-500"
            />
            <label htmlFor="terms" className="text-sm text-gray-300">
              I agree to the{" "}
              <Link href="/terms" className="text-blue-300 hover:text-blue-400 underline">
                Terms & Conditions
              </Link>
            </label>
          </div>

          {/* Signup Button */}
          <button
            className={`w-full py-2 rounded-lg ${
              isChecked
                ? "bg-blue-500 hover:bg-blue-600"
                : "bg-gray-600 cursor-not-allowed"
            }`}
            disabled={!isChecked}>
            <Link href="/">
            Create Account & Stay Safe
            </Link>
          </button>

          <p className="mt-3 text-sm text-gray-300">
            Already have an account?{" "}
            <Link href="/pages/login" className="text-blue-300 hover:text-blue-400 hover:underline">
              Login
            </Link>
          </p>
        </div>
      </SlideIn>
    </div>
  );
}
