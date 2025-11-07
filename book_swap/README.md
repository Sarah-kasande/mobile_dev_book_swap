# BookSwap - Student Textbook Exchange App

A Flutter mobile application that allows students to list textbooks they wish to exchange and initiate swap offers with other users. Built with Firebase for authentication, data storage, and real-time updates.

## Features

### 🔐 Authentication
- User signup with email/password
- Email verification required before login
- Secure Firebase Authentication
- User profile management

### 📚 Book Management (CRUD)
- **Create**: Post books with title, author, condition, and cover image
- **Read**: Browse all available listings in a shared feed
- **Update**: Edit your own book listings
- **Delete**: Remove your book listings

### 🔄 Swap Functionality
- Initiate swap offers by tapping "Swap" button
- Real-time swap state updates (Pending, Accepted, Rejected)
- Book availability automatically managed
- Both sender and recipient see updates instantly

### 💬 Chat System
- Real-time messaging between users after swap acceptance
- Chat rooms created automatically for accepted swaps
- Message history and timestamps

### 🧭 Navigation
- Bottom navigation with 4 main screens:
  - **Browse**: View all available books
  - **My Books**: Manage your listings and swap offers
  - **Chats**: Message other users
  - **Settings**: Profile and app preferences

### ⚙️ Settings
- Toggle notification preferences
- View profile information
- App information and help

## Technical Architecture

### State Management
- **Provider Pattern** for reactive state management
- Separate providers for Auth, Books, Swaps, and Chat
- Real-time UI updates with Firebase streams

### Database Schema
- **Users Collection**: User profiles and authentication data
- **Books Collection**: Book listings with metadata
- **Swaps Collection**: Swap offers and status tracking
- **ChatRooms Collection**: Chat room metadata
- **Messages Subcollection**: Individual chat messages

### Clean Architecture
```
lib/
├── models/          # Data models
├── services/        # Firebase service layer
├── providers/       # State management
├── screens/         # UI screens organized by feature
├── widgets/         # Reusable UI components
└── utils/          # Constants and utilities
```

## Firebase Configuration

### Collections Structure
- `users/`: User profiles and metadata
- `books/`: Book listings with owner information
- `swaps/`: Swap offers with status tracking
- `chatRooms/`: Chat room metadata and participants
- `chatRooms/{id}/messages/`: Individual chat messages

### Storage
- Book cover images stored in Firebase Storage
- Automatic image compression and optimization

### Real-time Features
- Live book listing updates
- Instant swap status changes
- Real-time chat messaging
- Automatic UI synchronization

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Firebase project with Authentication, Firestore, and Storage enabled
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd book_swap
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Firebase Storage
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Rules

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Books are readable by all authenticated users
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.ownerId;
    }
    
    // Swaps are readable/writable by participants
    match /swaps/{swapId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.requesterId || 
         request.auth.uid == resource.data.ownerId);
    }
    
    // Chat rooms and messages for participants only
    match /chatRooms/{chatRoomId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

**Storage Security Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /books/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Key Features Implementation

### Real-time Sync
- Firebase Firestore streams for live data updates
- Automatic UI refresh when data changes
- Optimistic updates for better user experience

### Image Handling
- Image picker for book covers
- Automatic upload to Firebase Storage
- Cached network images for performance
- Image compression to reduce storage costs

### Error Handling
- Comprehensive error handling throughout the app
- User-friendly error messages
- Loading states and progress indicators

### Performance Optimizations
- Efficient data queries with proper indexing
- Image caching and lazy loading
- Minimal rebuilds with Provider pattern

## Testing

Run the analyzer to check for issues:
```bash
flutter analyze
```

## Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and analyzer
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, contact: support@bookswap.com