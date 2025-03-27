import mongoose from "mongoose";

const MONGODB_URI = process.env.MONGO_URI;

if (!MONGODB_URI) {
  throw new Error("⚠️ Please define the MONGODB_URI environment variable.");
}

let isConnected = false;

export async function connectToDatabase() {
  if (isConnected) {
    console.log("✅ Using existing MongoDB connection.");
    return;
  }

  try {
    await mongoose.connect(MONGODB_URI as string, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    } as any);
    
    isConnected = true;
    console.log("✅ MongoDB Connected Successfully!");
  } catch (error) {
    console.error("❌ MongoDB Connection Failed:", error);
    process.exit(1);
  }
}
