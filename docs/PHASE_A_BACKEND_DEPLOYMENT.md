# Phase A Deployment (Spark Plan)

## Scope
This project now uses Firebase Spark (free tier) and does not require Cloud Functions.
Phase A features are implemented with Firebase Auth + Firestore directly from the app.

## Current Architecture
- Consent submit/read: client writes to and reads from `users/{uid}/consent`
- Account deletion: client deletes user data in Firestore, then deletes Firebase Auth user
- Security: Firestore Rules enforce per-user data access

## Prerequisites
- Firebase CLI installed
- Firebase project linked (`.firebaserc` points to `nozofibi`)
- Firestore enabled in Firebase Console

## Deploy Steps
```bash
cd c:\Users\LENOVO\Desktop\Nozofibi
flutter pub get
firebase deploy --only "firestore:rules"
```

## Validation Checklist
- Firestore rules deploy successfully
- User can submit consent
- User can view consent history
- Account deletion works for recently signed-in users
- If user session is old, app asks for sign-in again (re-auth flow)

## Notes
- No Blaze upgrade is required for this setup.
- No Functions deployment is needed.
- If account deletion returns re-auth errors, user must authenticate again.
