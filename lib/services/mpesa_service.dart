import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MpesaService {
  // M-Pesa Credentials
  static const String consumerKey = "RlBmHWIgFn11NPfmxQ0VC95Ao7yisZJ6WPFTaCIxTosOdMoI";
  static const String consumerSecret = "xkf1CmUxNUud1vaVZg87X6Z1uAg3NpVksgtdACBVgomZy9GAlKb2cS7MBi3ZtNAf";
  // Use local server for testing (Firebase Functions require paid plan)
  static const String baseUrl = "http://localhost:3000";
  
  // Business Details
  static const String businessShortCode = "174379"; // M-Pesa test code
  static const String passkey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";
  // Callback URL from ngrok
  static const String callbackUrl = "https://9d91b7bf6311.ngrok-free.app/api/payments/mpesa/callback";

  /// Generate Access Token
  static Future<String?> _getAccessToken() async {
    try {
      final credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
      final tokenUrl = '$baseUrl/oauth/access_token?grant_type=client_credentials';
      
      print('🔐 Requesting token from: $tokenUrl');
      
      final response = await http.get(
        Uri.parse(tokenUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Token request timeout'),
      );

      print('📊 Response status: ${response.statusCode}');
      final bodyPreview = response.body.length > 100 
          ? response.body.substring(0, 100) 
          : response.body;
      print('📊 Response body: $bodyPreview');;
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Access Token obtained successfully');
        return data['access_token'];
      } else {
        print('❌ Token Error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting access token: $e');
      return null;
    }
  }

  /// Generate Timestamp
  static String _generateTimestamp() {
    final now = DateTime.now();
    return '${now.year}${_pad(now.month)}${_pad(now.day)}${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');

  /// Generate Password (base64 encoded shortcode + passkey + timestamp)
  static String _generatePassword(String timestamp) {
    final data = '$businessShortCode$passkey$timestamp';
    return base64.encode(utf8.encode(data));
  }

  /// Initiate STK Push Payment
  static Future<Map<String, dynamic>> initiateSTKPush({
    required String phone,
    required double amount,
    required String orderId,
    String description = "Payment for food delivery order",
  }) async {
    try {
      // Normalize phone number - works with any Kenyan format
      String normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
      
      // If empty after removing non-digits, return error
      if (normalizedPhone.isEmpty) {
        return {
          'success': false,
          'message': '❌ Invalid phone number. Please enter a valid Kenyan number.',
        };
      }
      
      // If starts with 0 (Kenya format), replace with 254
      if (normalizedPhone.startsWith('0')) {
        normalizedPhone = '254${normalizedPhone.substring(1)}';
      }
      // If less than 10 digits, add 254
      else if (normalizedPhone.length <= 10 && !normalizedPhone.startsWith('254')) {
        normalizedPhone = '254$normalizedPhone';
      }
      // If doesn't start with 254, add it
      else if (!normalizedPhone.startsWith('254')) {
        normalizedPhone = '254$normalizedPhone';
      }

      // Final validation: must be 254 + 9 digits = 12 total
      if (normalizedPhone.length != 12 || !normalizedPhone.startsWith('254')) {
        return {
          'success': false,
          'message': '❌ Invalid phone format. Use format like 0700000000 or +254700000000',
        };
      }

      print('✅ Normalized phone: $normalizedPhone');
      print('📱 Initiating STK Push for: $normalizedPhone, Amount: KES $amount');

      final token = await _getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'message': '❌ Failed to connect to M-Pesa. Check your connection.',
        };
      }

      final timestamp = _generateTimestamp();
      final password = _generatePassword(timestamp);

      final payload = {
        'BusinessShortCode': businessShortCode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.toInt(),
        'PartyA': normalizedPhone,
        'PartyB': businessShortCode,
        'PhoneNumber': normalizedPhone,
        'CallBackURL': callbackUrl,
        'AccountReference': orderId,
        'TransactionDesc': description,
      };

      print('📤 Sending STK Push to local server...');
      print('🔗 Endpoint: $baseUrl/mpesa/stkpush');

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpush'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('⏱️ Request timeout - Check your internet'),
      );

      final responseData = jsonDecode(response.body);
      print('📨 M-Pesa Response: $responseData');
      print('📊 Status Code: ${response.statusCode}');
      print('📊 ResponseCode: ${responseData['ResponseCode']}');
      print('📊 Success field: ${responseData['success']}');

      if (response.statusCode == 200 && responseData['ResponseCode'] == '0') {
        print('✅ STK Push sent successfully!');
        
        // Try to save payment record (but don't fail if Firestore has permission issues)
        try {
          await _savePaymentRecord(
            phone: normalizedPhone,
            amount: amount,
            orderId: orderId,
            checkoutId: responseData['CheckoutRequestID'],
            status: 'pending',
          );
        } catch (e) {
          print('⚠️  Note: Could not save to Firestore (${e.toString()}), but payment request was sent');
        }

        return {
          'success': true,
          'message': '✅ M-Pesa prompt sent! Check your phone and enter your PIN.',
          'customerMessage': responseData['CustomerMessage'] ?? 'Enter your M-Pesa PIN to complete this transaction',
          'checkoutId': responseData['CheckoutRequestID'],
          'phone': normalizedPhone,
        };
      } else {
        final errorMsg = responseData['ResponseDescription'] ?? 
                        responseData['errorMessage'] ?? 
                        'Payment initiation failed';
        return {
          'success': false,
          'message': '❌ $errorMsg',
          'code': responseData['ResponseCode'],
        };
      }
    } catch (e) {
      print('❌ STK Push Error: $e');
      return {
        'success': false,
        'message': '❌ Error: $e',
      };
    }
  }

  /// Save Payment Record to Firestore
  static Future<void> _savePaymentRecord({
    required String phone,
    required double amount,
    required String orderId,
    required String checkoutId,
    required String status,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('payments').add({
        'userId': user.uid,
        'userEmail': user.email,
        'phone': phone,
        'amount': amount,
        'orderId': orderId,
        'checkoutId': checkoutId,
        'status': status,
        'paymentMethod': 'mpesa',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Payment record saved for order: $orderId');
    } catch (e) {
      print('Error saving payment record: $e');
    }
  }

  /// Update Payment Status
  static Future<void> updatePaymentStatus(String checkoutId, String status) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('checkoutId', isEqualTo: checkoutId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // If successful, update order status
        if (status == 'completed') {
          final orderId = snapshot.docs.first['orderId'];
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .update({
            'status': 'confirmed',
            'paid': true,
            'paymentMethod': 'mpesa',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  /// Query Payment Status
  static Future<Map<String, dynamic>> queryPaymentStatus(String checkoutId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Failed to get access token'};
      }

      final timestamp = _generateTimestamp();
      final password = _generatePassword(timestamp);

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpushquery'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'BusinessShortCode': businessShortCode,
          'Password': password,
          'Timestamp': timestamp,
          'CheckoutRequestID': checkoutId,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Query request timeout'),
      );

      final data = jsonDecode(response.body);
      print('Query Response: $data');

      if (response.statusCode == 200) {
        // 0 = successful, other codes indicate various states
        final isSuccessful = data['ResultCode'] == '0';
        
        if (isSuccessful) {
          await updatePaymentStatus(checkoutId, 'completed');
        }

        return {
          'success': isSuccessful,
          'resultCode': data['ResultCode'],
          'resultDesc': data['ResultDesc'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Query failed',
        };
      }
    } catch (e) {
      print('Error querying payment status: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Send STK Push Prompt to Phone (Works with any Kenyan number)
  static Future<bool> sendPrompt(String phone) async {
    try {
      // Normalize phone
      String normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
      
      if (normalizedPhone.isEmpty) {
        print('❌ Phone number is empty');
        return false;
      }
      
      if (normalizedPhone.startsWith('0')) {
        normalizedPhone = '254${normalizedPhone.substring(1)}';
      } else if (!normalizedPhone.startsWith('254')) {
        normalizedPhone = '254$normalizedPhone';
      }

      print('📱 Sending STK prompt to: $normalizedPhone');

      // Trigger payment request to send STK prompt
      final result = await initiateSTKPush(
        phone: normalizedPhone,
        amount: 1, // Minimum for testing
        orderId: 'PROMPT_${DateTime.now().millisecondsSinceEpoch}',
        description: 'M-Pesa STK Prompt - Enter PIN',
      );

      return result['success'] ?? false;
    } catch (e) {
      print('❌ Error sending prompt: $e');
      return false;
    }
  }
}
