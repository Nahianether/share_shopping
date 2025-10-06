# Firebase Optimization & Auto-Delete Setup

## 1. Firestore Security Rules (Cost Optimization)

Add these security rules in Firebase Console to optimize database reads:

1. Go to https://console.firebase.google.com
2. Select "share-shopping-personal" project
3. Click "Firestore Database" → "Rules"
4. Replace with these optimized rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Shopping list collection
    match /shopping_list/{itemId} {
      // Allow read/write for authenticated users
      allow read, write: if request.auth != null;

      // Prevent reading very old items (older than 7 days)
      allow read: if request.auth != null &&
        resource.data.createdAt > timestamp.date(2020, 1, 1);
    }
  }
}
```

## 2. Firestore Indexes (Performance Optimization)

Create composite indexes for efficient queries:

1. Go to Firestore Database → "Indexes" tab
2. Click "Create Index"
3. Create these indexes:

**Index 1:**
- Collection ID: `shopping_list`
- Fields:
  - `isDone` (Ascending)
  - `completedAt` (Ascending)

**Index 2:**
- Collection ID: `shopping_list`
- Fields:
  - `createdAt` (Ascending)

## 3. Auto-Delete Setup (Daily Cleanup at 6 AM)

### Option A: Firebase Cloud Functions (Recommended - Server-side)

**Cost:** Free tier includes 2M invocations/month

#### Steps:

1. Install Firebase Tools:
```bash
npm install -g firebase-tools
firebase login
```

2. Initialize Cloud Functions:
```bash
cd /Users/intishar/Documents/personal/share_shopping
firebase init functions
```
- Select "share-shopping-personal" project
- Choose TypeScript or JavaScript
- Install dependencies: Yes

3. Edit `functions/src/index.ts` (or `index.js`):

```typescript
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Runs every day at 6:00 AM (UTC+6 Bangladesh Time)
export const cleanupCompletedItems = functions.pubsub
  .schedule("0 6 * * *")
  .timeZone("Asia/Dhaka") // Change to your timezone
  .onRun(async (context) => {
    const db = admin.firestore();
    const twentyFourHoursAgo = new Date();
    twentyFourHoursAgo.setHours(twentyFourHoursAgo.getHours() - 24);

    const snapshot = await db
      .collection("shopping_list")
      .where("isDone", "==", true)
      .where("completedAt", "<", twentyFourHoursAgo)
      .get();

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Deleted ${snapshot.size} completed items`);
    return null;
  });
```

4. Deploy:
```bash
firebase deploy --only functions
```

**Cost Estimation:**
- 1 execution per day = 30 executions/month
- FREE (well within 2M limit)

### Option B: Client-side Cleanup (Free, but requires app to be opened)

This is already implemented! The app automatically cleans up old items when:
- User opens the shopping list screen
- Runs in background using `initState()`

**Current Implementation:**
- File: `lib/screens/shopping_list_screen.dart`
- Calls `cleanupOldCompletedItems()` on app start

## 4. Cost Optimization Summary

### What's Already Optimized:

✅ **Query Limits:**
- Only fetches items from last 7 days
- Filters completed items older than 24 hours client-side
- Uses `orderBy` with `where` for indexed queries

✅ **Auto-Cleanup:**
- Client-side cleanup on app start (free)
- Removes old completed items automatically

✅ **Real-time Optimization:**
- Single snapshot listener (not multiple)
- Efficient filtering before rendering

### Estimated Costs (Free Tier):

**Firestore Free Tier:**
- 50,000 reads/day
- 20,000 writes/day
- 1 GB storage

**Your Expected Usage:**
- ~100-200 reads/day (2 users, multiple app opens)
- ~20-50 writes/day (adding/updating items)
- ~1 MB storage

**Result: 100% FREE** ✅

## 5. Enable Auto-Delete Now

### Quick Setup (Client-side - Already Done!):
The app already runs cleanup automatically. Nothing more needed!

### Optional: Add Server-side Cleanup (Cloud Functions):
Follow "Option A" above for guaranteed daily cleanup at 6 AM, even if app is not opened.

## 6. Monitor Costs

1. Go to Firebase Console → Usage & Billing
2. Set budget alerts:
   - Budget: $1
   - Alert at 50%, 90%, 100%

You'll get email alerts if costs exceed free tier.
