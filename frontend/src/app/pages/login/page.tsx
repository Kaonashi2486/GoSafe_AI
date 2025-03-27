"use client";
import Link from "next/link";
import React, { useState } from "react";
import { useRouter } from "next/navigation";
import SlideIn from "@/app/components/SlideIn";

export default function Login() {
  const router = useRouter();
  
  // Predefined admin credentials
  const ADMIN_EMAIL = "admin@example.com";
  const ADMIN_PASSWORD = "securepassword123";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errorMessage, setErrorMessage] = useState("");

  const handleLogin = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    // Check if entered credentials match the predefined admin credentials
    if (email === ADMIN_EMAIL && password === ADMIN_PASSWORD) {
      router.push("/"); // Redirect to home page
    } else {
      setErrorMessage("Invalid credentials. Please try again.");
    }
  };

  return (
    <div
      className="h-screen bg-cover bg-center flex justify-center items-center"
      style={{ backgroundImage: "url('/login_bg.png')" }}
    >
      <SlideIn direction="left">
        <div className="bg-gray-800 bg-opacity-80 p-6 rounded-lg shadow-lg w-full max-w-md mx-4 md:mx-0">
          <h2 className="text-2xl font-bold text-blue-300 mb-4">Admin Login</h2>

          {/* Display error message if login fails */}
          {errorMessage && <p className="text-red-500 text-sm mb-3">{errorMessage}</p>}

          <form onSubmit={handleLogin}>
            <input
              type="email"
              placeholder="Email"
              className="w-full p-2 mb-3 bg-gray-700 text-white rounded"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <input
              type="password"
              placeholder="Password"
              className="w-full p-2 mb-3 bg-gray-700 text-white rounded"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <button
              type="submit"
              className="w-full py-2 bg-blue-500 hover:bg-blue-600 rounded-lg hover:shadow-lg text-white hover:text-bold"
            >
              Sign In Securely!
            </button>
          </form>
        </div>
      </SlideIn>
    </div>
  );
}