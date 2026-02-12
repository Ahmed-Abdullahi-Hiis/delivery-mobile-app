# How to Update Firestore Security Rules

## Quick Fix for Permissions Issue

Your app is getting "permission-denied" errors because Firestore security rules are blocking writes. Here's how to fix it:

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **delivery-mobile-app**
3. Go to **Firestore Database** (left sidebar)

### Step 2: Update Security Rules
1. Click the **Rules** tab at the top
2. Replace ALL the code with the rules from `firestore.rules` file in this project

### Step 3: Publish Rules
1. Click **Publish** button
2. Confirm the deployment

---

## What These Rules Do

✅ **Allow authenticated users to:**
- Create orders for themselves
- Read their own orders
- Create payment records

✅ **Allow admins to:**
- Read all orders
- Update any order
- Delete orders (if needed)

✅ **Security features:**
- Users can only modify their own data (unless admin)
- Prevents unauthorized access
- Admin checks via `isAdmin` field in user document

---

## Troubleshooting

### If still getting permission errors:

**Option 1: Temporary Fix (For Testing Only - NOT for production)**
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

**Option 2: Check User Document**
Make sure your user document in Firestore has the correct structure:
```json
users/{userId}
  - email: "user@example.com"
  - name: "John Doe"
  - isAdmin: false  // (true only for admins)
```

---

## Important Notes

- Rules take effect immediately after publishing
- Clear app cache and restart if changes don't work
- Make sure you're logged in with a valid Firebase user
- Admin users need `isAdmin: true` in their user document
