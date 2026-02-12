# ✅ FIRESTORE RULES FIX - Payment Update Issue

## The Problem
Your Firestore rules are preventing users from updating their own orders to set `paid: true` after payment succeeds.

## The Solution

Your **current rules** (the ones you showed me) have this:
```firestore
match /orders/{orderId} {
  allow read, update, delete: if isAdmin();
  allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
  allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
}
```

**The issue:** Users can CREATE orders, but CANNOT UPDATE them!

## What You Need to Do

### Option 1: Use Updated Rules (Recommended)
Replace your `/orders/{orderId}` section with this:

```firestore
match /orders/{orderId} {
  // Admin can read/update/delete any order
  allow read, update, delete: if isAdmin();

  // User can read their own orders
  allow read: if isSignedIn() &&
    resource.data.userId == request.auth.uid;

  // User can create only their own order
  allow create: if isSignedIn() &&
    request.resource.data.userId == request.auth.uid;

  // ✅ THIS IS THE FIX: User can update their own order
  allow update: if isSignedIn() &&
    resource.data.userId == request.auth.uid;
}
```

### Option 2: Use the Full Rules File
Copy ALL the rules from `firestore.rules` file in your project (it already has the correct rules).

## Steps to Apply

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **Firestore Database** → **Rules** tab
4. Replace the `/orders/{orderId}` section with the code above
5. Click **Publish**
6. Wait for "✅ Rules deployed successfully"
7. Restart your Flutter app
8. Test the payment again

## What This Fixes

✅ Users can now update their own orders
✅ Payment confirmation will successfully set `paid: true`
✅ Status will change to `preparing`
✅ No more permission-denied errors

---

## Note
The rules ensure that:
- Users can only update their OWN orders
- Admins can update any order
- Users cannot modify orders they don't own
- This is secure and proper access control
