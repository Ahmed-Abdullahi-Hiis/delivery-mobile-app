require("dotenv").config();
const express = require("express");
const cors = require("cors");
const axios = require("axios");

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

console.log("🚀 Starting M-Pesa Backend Server (REAL SAFARICOM)...");
console.log("✅ Using REAL working credentials");

// M-Pesa Configuration
const CONSUMER_KEY = process.env.MPESA_CONSUMER_KEY;
const CONSUMER_SECRET = process.env.MPESA_CONSUMER_SECRET;

if (!CONSUMER_KEY || !CONSUMER_SECRET) {
  console.error("❌ ERROR: Missing MPESA_CONSUMER_KEY or MPESA_CONSUMER_SECRET in .env file!");
  process.exit(1);
}

console.log("✅ Credentials loaded from .env");

// Get Access Token from Safaricom
async function getAccessToken() {
  try {
    const auth = Buffer.from(`${CONSUMER_KEY}:${CONSUMER_SECRET}`).toString("base64");
    const response = await axios.get(
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
      {
        headers: { Authorization: `Basic ${auth}` },
        timeout: 10000
      }
    );
    console.log("✅ Real token obtained from Safaricom");
    return response.data.access_token;
  } catch (error) {
    console.error("❌ Error getting token from Safaricom:", error.message);
    throw error;
  }
}

// Simple test endpoint
app.get("/test", (req, res) => {
  console.log("✅ /test endpoint called");
  res.json({ status: "ok", message: "Server is working!" });
});

// Health check
app.get("/health", (req, res) => {
  console.log("✅ /health endpoint called");
  res.json({ status: "healthy" });
});

// M-Pesa OAuth token endpoint
app.get("/oauth/access_token", async (req, res) => {
  console.log("\n🔥🔥🔥 ENDPOINT HIT! /oauth/access_token 🔥🔥🔥");
  console.log("📊 Query params:", req.query);
  
  try {
    const token = await getAccessToken();
    const response = {
      access_token: token,
      expires_in: 3599,
      token_type: "Bearer"
    };
    console.log("✅ Sending real token to app");
    res.json(response);
  } catch (error) {
    console.error("❌ Error:", error.message);
    res.status(500).json({ error: error.message });
  }
});

// STK Push endpoint - REAL SAFARICOM
app.post("/mpesa/stkpush", async (req, res) => {
  console.log("\n🔥🔥🔥 ENDPOINT HIT! /mpesa/stkpush 🔥🔥🔥");
  console.log("📊 Request body:", JSON.stringify(req.body, null, 2));
  
  try {
    // Get token
    const token = await getAccessToken();
    
    console.log("📤 Forwarding to Safaricom: https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest");
    
    // Send to Safaricom
    const response = await axios.post(
      "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
      req.body,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json"
        },
        timeout: 10000
      }
    );
    
    console.log("✅ Response from Safaricom:", response.data);
    res.json(response.data);
  } catch (error) {
    console.error("❌ Error from Safaricom:", error.response ? error.response.data : error.message);
    res.status(500).json({
      error: error.message,
      details: error.response ? error.response.data : null
    });
  }
});

// ================= CALLBACK ENDPOINT =================
app.post("/mpesa-callback", (req, res) => {
  console.log("\n📨 MPESA CALLBACK RECEIVED:");
  console.log(JSON.stringify(req.body, null, 2));
  
  // Always respond with success
  res.json({ ResultCode: 0, ResultDesc: "Accepted" });
});

// Error handler
app.use((err, req, res, next) => {
  console.error("❌ Error:", err);
  res.status(500).json({ error: err.message });
});

// 404 handler
app.use((req, res) => {
  console.log(`❌ 404 - ${req.method} ${req.path}`);
  res.status(404).json({ error: "Not found" });
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Server listening on http://localhost:${PORT}`);
  console.log(`🎭 DEMO MODE - Accepts ANY Kenyan phone number`);
  console.log(`📱 Test payment flow with your Flutter app`);
});
