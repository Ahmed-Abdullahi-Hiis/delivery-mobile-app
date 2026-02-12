# URGENT: Fix Firestore Permission Errors

## The Problem
Your app is failing with: `[cloud_firestore/permission-denied] Missing or insufficient permissions`

This happens when trying to:
1. Save order to Firestore
2. Update order status to "paid"
3. Save payment records

## The Solution (3 Steps)

### STEP 1: Copy Security Rules
The file `firestore.rules` in this project contains the correct security rules.

### STEP 2: Go to Firebase Console
1. Visit: https://console.firebase.google.com/
2. Select your project
3. Click **Firestore Database** (left sidebar)

### STEP 3: Update Rules
1. Click the **Rules** tab (at the top)
2. Select **All** the text in the editor (Ctrl+A)
3. **Delete** it all
4. **Copy** the entire content from `firestore.rules` file
5. **Paste** it into the Firebase Rules editor
6. Click **Publish** button
7. Wait for "✅ Rules published successfully"

---

## TEMPORARY FIX (For Testing - NOT Production!)

If the above doesn't work immediately, use this temporary rule:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Then after testing works, switch to the proper rules in `firestore.rules`.

---

## What To Do Now

1. ✅ Copy the firestore.rules content
2. ✅ Go to Firebase Console
3. ✅ Replace the rules
4. ✅ Click Publish
5. ✅ Wait 30 seconds
6. ✅ Restart your Flutter app
7. ✅ Try the payment again

---

## Verify It Works

After publishing rules, you should see in the console:
- ✅ Order saves to Firestore
- ✅ Order updates to `paid: true`
- ✅ Status changes to `preparing`
- ❌ NO MORE permission errors
