import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import next from "next";
import User from "./src/app/models/userModels.js";

dotenv.config();

const dev = process.env.NODE_ENV !== "production";
const app = next({ dev });
const handle = app.getRequestHandler();
const server = express();

// Middleware
server.use(express.json());
server.use(cors());

// MongoDB Connection
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("MongoDB Connected");
  } catch (error) {
    console.error("Database connection failed:", error);
    process.exit(1);
  }
};

// API Route to Fetch User Info
server.get("/api/users", async (req, res) => {
  try {
    const users = await User.find(); // Fetch all users from MongoDB
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: "Error fetching users", error: error.message });
  }
});

// Start Next.js and Express server
app.prepare().then(() => {
  server.all("*", (req, res) => {
    return handle(req, res);
  });

  const PORT = process.env.PORT || 3000;
  server.listen(PORT, async () => {
    await connectDB();
    console.log(`Server running on http://localhost:${PORT}`);
  });
});
