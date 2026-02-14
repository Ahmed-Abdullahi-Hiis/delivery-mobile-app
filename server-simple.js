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

// Store callback data in memory
let lastCallbackData = null;

// ================= CHECK TRANSACTION STATUS =================
app.get("/check-payment/:orderId/:phone", async (req, res) => {
  const { orderId, phone } = req.params;
  console.log(`\n🔍 Checking payment status for Order: ${orderId}, Phone: ${phone}`);
  
  try {
    // Only return success if we actually received a callback for this phone
    if (lastCallbackData && lastCallbackData.phoneNumber == phone && lastCallbackData.success === true) {
      console.log("✅ Payment found in callback data!");
      res.json({
        success: true,
        paid: true,
        receipt: lastCallbackData.mpesaReceiptNumber,
        amount: lastCallbackData.amount,
        timestamp: lastCallbackData.timestamp
      });
      return;
    }
    
    // No callback yet - payment still pending
    console.log("⏳ No payment confirmation yet for this phone");
    res.json({
      success: false,
      paid: false,
      message: "Payment not yet confirmed",
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error("❌ Error checking payment:", error.message);
    res.status(500).json({ error: error.message });
  }
});

// ================= CALLBACK ENDPOINT =================
app.post("/mpesa-callback", (req, res) => {
  console.log("\n📨 MPESA CALLBACK RECEIVED:");
  console.log(JSON.stringify(req.body, null, 2));
  
  try {
    // Extract M-Pesa response data
    const result = req.body.Body?.stkCallback || {};
    const resultCode = result.ResultCode;
    const callbackMetadata = result.CallbackMetadata?.Item || [];
    
    console.log("📊 Result Code:", resultCode);
    
    // Check if payment was successful (ResultCode 0 = success)
    if (resultCode === 0) {
      console.log("✅ PAYMENT SUCCESSFUL!");
      
      // Extract data from callback
      let mpesaReceiptNumber = "";
      let phoneNumber = "";
      let amount = 0;
      
      for (const item of callbackMetadata) {
        if (item.Name === "MpesaReceiptNumber") mpesaReceiptNumber = item.Value;
        if (item.Name === "PhoneNumber") phoneNumber = item.Value;
        if (item.Name === "Amount") amount = item.Value;
      }
      
      console.log(`💰 Payment Details - Phone: ${phoneNumber}, Amount: ${amount}, Receipt: ${mpesaReceiptNumber}`);
      
      // Store callback for app to retrieve
      lastCallbackData = {
        timestamp: new Date().toISOString(),
        phoneNumber: phoneNumber,
        mpesaReceiptNumber: mpesaReceiptNumber,
        amount: amount,
        resultCode: resultCode,
        success: true
      };
      
      console.log("✅ Callback data stored for app retrieval");
    } else {
      console.log("⚠️ Payment failed or user cancelled (ResultCode:", resultCode, ")");
      lastCallbackData = {
        resultCode: resultCode,
        success: false
      };
    }
  } catch (error) {
    console.error("❌ Error processing callback:", error.message);
  }
  
  // Always respond with success to M-Pesa
  res.json({ ResultCode: 0, ResultDesc: "Accepted" });
});

// ================= VERIFY PAYMENT ENDPOINT =================
app.get("/verify-payment/:phone", (req, res) => {
  const phone = req.params.phone;
  console.log(`\n🔍 Payment verification requested for: ${phone}`);
  
  if (lastCallbackData && lastCallbackData.phoneNumber == phone) {
    console.log("✅ Payment confirmation found!");
    res.json({
      confirmed: true,
      data: lastCallbackData
    });
    // Clear after retrieval to prevent duplicate confirmations
    lastCallbackData = null;
  } else {
    console.log("⏳ No payment confirmation yet");
    res.json({
      confirmed: false,
      message: "Payment not yet confirmed"
    });
  }
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
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server listening on http://0.0.0.0:${PORT}`);
  console.log(`✅ Server listening on http://localhost:${PORT}`);
  console.log(`🎭 DEMO MODE - Accepts ANY Kenyan phone number`);
  console.log(`📱 Test payment flow with your Flutter app`);
});

// Handle server errors
server.on('error', (err) => {
  console.error('❌ Server error:', err.message);
  if (err.code === 'EADDRINUSE') {
    console.error(`Port ${PORT} is already in use`);
    process.exit(1);
  }
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err.message);
  console.error(err.stack);
});

// Handle unhandled rejections  
process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection:', reason);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n📌 Shutting down gracefully...');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});
