# Firebase Storage Setup Guide

Your app is currently saving books without images because Firebase Storage is not yet configured. Follow these steps to enable image uploads:

## Step 1: Enable Firebase Storage
1. Go to [Firebase Console](https://console.firebase.google.com/project/bookswap-5b6c5/storage)
2. Click "Get Started" to enable Firebase Storage
3. Choose "Start in test mode" for now (we'll secure it later)
4. Select a location for your storage bucket (choose the same region as your Firestore)

## Step 2: Configure Storage Rules
After enabling storage, the app should automatically work with images. The storage rules are already configured in your project.

## Step 3: Test Image Upload
1. Run your app: `flutter run -d chrome`
2. Add a new book with an image
3. Check if the image appears in the book listing

## Troubleshooting
If images still don't work:
1. Check browser console for errors (F12 → Console)
2. Verify Firebase Storage is enabled in Firebase Console
3. Make sure you're logged in to the app

## Current Status
- ✅ Firestore (database) is working
- ✅ Authentication is working  
- ❌ Storage (images) needs to be enabled
- ✅ App saves books without images as fallback