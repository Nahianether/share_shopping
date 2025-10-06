# Shared Shopping List 🛒

A beautiful, real-time shopping list app built with Flutter and Firebase that allows couples to share their shopping needs seamlessly.

## Features ✨

- 🔄 **Real-time Sync** - Items sync instantly between partners
- 🎨 **Modern UI** - Beautiful gradient design with smooth animations
- ✏️ **Edit & Delete** - Manage items with ease
- ⏰ **Time Tracking** - See when items were added
- 🗑️ **Auto-cleanup** - Completed items auto-delete after 24 hours
- 💰 **Cost Optimized** - Efficient Firebase queries to stay in free tier
- 🔒 **Secure** - Environment variables protect sensitive data

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.8.1)
- Firebase account
- Dart

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/share_shopping.git
   cd share_shopping
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**

   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)

   b. Enable the following services:
   - Authentication (Anonymous)
   - Firestore Database

   c. Run FlutterFire CLI to configure:
   ```bash
   flutterfire configure
   ```

4. **Configure Environment Variables**

   a. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

   b. Fill in your Firebase credentials in `.env`:
   ```env
   FIREBASE_WEB_API_KEY=your_web_api_key_here
   FIREBASE_WEB_APP_ID=your_web_app_id_here
   FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id_here
   FIREBASE_PROJECT_ID=your_project_id_here
   FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
   FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com
   FIREBASE_ANDROID_API_KEY=your_android_api_key_here
   FIREBASE_ANDROID_APP_ID=your_android_app_id_here
   FIREBASE_IOS_API_KEY=your_ios_api_key_here
   FIREBASE_IOS_APP_ID=your_ios_app_id_here
   FIREBASE_IOS_BUNDLE_ID=com.example.shareShopping
   FIREBASE_WINDOWS_APP_ID=your_windows_app_id_here
   ```

   You can find these values in:
   - Firebase Console → Project Settings → Your apps
   - Or use `flutterfire configure` to generate them

5. **Enable Firestore Database**

   a. Go to Firebase Console → Firestore Database

   b. Click "Create database"

   c. Choose "Start in test mode" (for development)

   d. Select a location and click "Enable"

6. **Enable Anonymous Authentication**

   a. Go to Firebase Console → Authentication

   b. Click "Get started"

   c. Enable "Anonymous" provider

   d. Click "Save"

7. **Run the app**
   ```bash
   flutter run
   ```

## How It Works

1. **Sign In**: Each partner selects their role (Husband/Wife/Partner) and enters their name
2. **Add Items**: Tap the + button to add shopping items
3. **Real-time Sync**: Items appear instantly on partner's device
4. **Mark as Done**: Check the checkbox when item is purchased
5. **Auto-delete**: Completed items automatically delete after 24 hours
6. **Edit/Delete**: Use the 3-dot menu to edit or delete items

## Architecture

- **State Management**: Riverpod
- **Backend**: Firebase (Firestore + Anonymous Auth)
- **UI Framework**: Flutter Material Design
- **Environment Config**: flutter_dotenv

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration (uses .env)
├── models/
│   └── shopping_item.dart    # Shopping item model
├── providers/
│   └── firebase_providers.dart # Riverpod providers
├── screens/
│   ├── auth_screen.dart      # Login screen
│   └── shopping_list_screen.dart # Main shopping list
└── services/
    └── firebase_service.dart # Firebase operations
```

## Cost Optimization

The app is optimized to stay within Firebase's free tier:

- ✅ Only fetches items from last 7 days
- ✅ Client-side filtering for completed items
- ✅ Single snapshot listener (not multiple)
- ✅ Batch delete operations
- ✅ Auto-cleanup of old items

**Expected Usage**: 100-200 reads/day, 20-50 writes/day = 100% FREE ✅

## Security

⚠️ **IMPORTANT**: Never commit the following files:
- `.env` (contains your Firebase credentials)
- `lib/firebase_options.dart` (auto-generated with credentials)
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

These files are already added to `.gitignore`.
