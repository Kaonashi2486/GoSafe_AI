"use client";
import { useState, useEffect } from "react";
import { getLoginCounts, getLocationData, updateAlphaBeta } from "@/app/utils/api";
import Navbar from "@/app/components/Navbar";
import Sidebar from "@/app/components/SideScroll";
import { Graphs } from "@/app/components/chart-line-dots";
import SlideIn from "@/app/components/SlideIn";
import OverviewCards from "@/app/components/OverviewCards";
import MapComponent from "@/app/components/MapComponent";


export default function AdminDashboard() {
  const [location, setLocation] = useState<string>("");
  const [loginCount, setLoginCount] = useState<number | null>(null);
  const [report, setReport] = useState<any>(null);
  const [alpha, setAlpha] = useState<number>(0);
  const [filterState,SetFilterState] = useState<string>("All");
  const [beta, setBeta] = useState<number>(0);
  const [analysis, setAnalysis] = useState<string>("");

  useEffect(() => {
    if (location) {
      fetchLocationData(location);
      fetchLoginCounts(location);
    }
  }, [location]);

  const fetchLocationData = async (loc: string) => {
    const data = await getLocationData(loc);
    setReport(data);
  };

  const fetchLoginCounts = async (loc: string) => {
    const count = await getLoginCounts(loc);
    setLoginCount(count);
  };

  const analyzeAlphaBeta = async () => {
    const response = await fetch("/api/analyze", {
      method: "POST",
      body: JSON.stringify({ alpha, beta }),
    });
    const data = await response.json();
    setAnalysis(data.result);
  };

  const handleUpdateAlphaBeta = async () => {
    await updateAlphaBeta(alpha, beta);
    alert("Alpha & Beta values updated successfully!");
  };

  const allPoints = [
    { coordinates: [72.8777, 19.0760], properties: { id: 1, name: "Gateway of India, Mumbai" } },
    { coordinates: [72.8354, 18.9220], properties: { id: 2, name: "Marine Drive, Mumbai" } },
    { coordinates: [72.8335, 18.9750], properties: { id: 3, name: "Chhatrapati Shivaji Terminus, Mumbai" } },
    { coordinates: [73.8567, 18.5204], properties: { id: 4, name: "Shaniwar Wada, Pune" } },
    { coordinates: [73.7898, 18.5522], properties: { id: 5, name: "Aga Khan Palace, Pune" } },
    { coordinates: [-74.006, 40.7128], properties: { id: 6, name: "Times Square, New York" } },
    { coordinates: [-73.9857, 40.7488], properties: { id: 7, name: "Empire State Building, New York" } },
    { "coordinates": [72.8493, 19.1197], "properties": { "id": 8, "name": "Andheri Sports Complex, Andheri" } },
  { "coordinates": [72.8540, 19.2288], "properties": { "id": 9, "name": "Sanjay Gandhi National Park, Borivali" } },
  { "coordinates": [72.8442, 19.0990], "properties": { "id": 10, "name": "NMIMS University, Vile Parle" } },
  { "coordinates": [72.8295, 19.0550], "properties": { "id": 11, "name": "Bandra-Worli Sea Link, Bandra" } },
  { "coordinates": [72.8420, 19.0184], "properties": { "id": 12, "name": "Siddhivinayak Temple, Dadar" } },
  { "coordinates": [72.8263, 19.1085], "properties": { "id": 13, "name": "Juhu Beach, Juhu" } },
  { "coordinates": [72.8102, 19.1385], "properties": { "id": 14, "name": "Versova Beach, Versova" } },
  { "coordinates": [72.9781, 19.2183], "properties": { "id": 15, "name": "Upvan Lake, Thane" } },
  { "coordinates": [72.9231, 19.0866], "properties": { "id": 16, "name": "R City Mall, Ghatkopar" } },
  { "coordinates": [72.8510, 19.3124], "properties": { "id": 17, "name": "Golden Nest, Bhayander" } },
  { "coordinates": [72.8194, 18.9691], "properties": { "id": 18, "name": "Mumbai Central Railway Station, Mumbai Central" } }
    ,
  ] as { coordinates: [number, number]; properties: { id: number; name: string } }[];
  

  const filteredPoints = location
    ? allPoints.filter((point) =>
        (location === "Mumbai" && point.coordinates[0] >= 72 && point.coordinates[0] <= 73) ||
        (location === "Pune" && point.coordinates[0] >= 73 && point.coordinates[0] <= 74) ||
        (location === "New York" && point.coordinates[0] <= -73 && point.coordinates[0] >= -75)
      )
    : [];

  return (
    <>
      <SlideIn direction="left">
        <Navbar />
        <Sidebar />
        <div className="bg-gray-900 text-white min-h-screen p-6 flex flex-col items-center">
          {/* Location Selection */}
          <div className="w-[180vh] h-[70vh] bg-gray-700 flex justify-center items-center">
            <MapComponent points={filterState === "All" ? allPoints : filteredPoints} location={location as "Mumbai" | "Pune" } />
          </div>

          <select
            className="bg-gray-700 p-4 rounded m-4"
            onChange={(e) => setLocation(e.target.value)}
          >
            <option value="">Select Location</option>
            <option value="Mumbai">Mumbai</option>
            <option value="Pune">Pune</option>
            <option value="New York">New York</option>
          </select>

          {/* Live Reports */}
          {report && (
            <div className="mt-4 p-4 bg-gray-800 rounded">
              <h2 className="text-xl font-bold">Live Reports</h2>
              <p>Crime: {report.crime}</p>
              <p>Weather: {report.weather}</p>
              <p>Incidents: {report.incidents}</p>
            </div>
          )}

          <div className="p-6">
            <h2 className="text-2xl font-bold mb-4">Overview</h2>
            <OverviewCards />
          </div>

          <div className="grid grid-cols-2 gap-20 mt-6 w-full max-w-4xl">
            <div>
              <p className="text-lg">Logins at {location}: {loginCount ?? "Loading..."}</p>
              <Graphs />
            </div>
            <div className="mt-6 p-4 bg-gray-800 rounded">
              <h2 className="text-xl font-bold">Alpha-Beta Analysis</h2>
              <input
                type="number"
                className="bg-gray-700 p-2 rounded mr-2"
                placeholder="Alpha"
                value={alpha}
                onChange={(e) =>{
                  setAlpha(Number(e.target.value))
                  SetFilterState(e.target.value)
                }}
              />
              <input
                type="number"
                className="bg-gray-700 p-2 rounded"
                placeholder="Beta"
                value={beta}
                onChange={(e) => setBeta(Number(e.target.value))}
              />
              <button
                onClick={analyzeAlphaBeta}
                className="ml-2 bg-blue-500 hover:bg-blue-600 p-2 rounded"
              >
                Analyze
              </button>
              <p className="mt-2">{analysis}</p>
              <button
                onClick={handleUpdateAlphaBeta}
                className="mt-4 bg-green-500 hover:bg-green-600 p-2 rounded"
              >
                Update Alpha-Beta in DB
              </button>
            </div>
          </div>
        </div>
      </SlideIn>
    </>
  );
}
