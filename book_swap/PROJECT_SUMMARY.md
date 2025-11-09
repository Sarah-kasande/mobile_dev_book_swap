# BookSwap - Mobile Book Exchange App

## 📱 Project Overview
BookSwap is a comprehensive Flutter mobile application that enables students to exchange textbooks with each other. The app provides a complete platform for listing books, browsing available books, requesting swaps, and communicating with other users.

## ✅ Implemented Features

### 🔐 Authentication System
- **User Registration**: Email/password signup with validation
- **User Login**: Secure authentication with Firebase Auth
- **Email Verification**: Email verification system for new accounts
- **Password Reset**: Forgot password functionality
- **Auto-login**: Persistent authentication state

### 📚 Book Management
- **Add Books**: Users can add books with photos, title, author, and condition
- **My Books**: View and manage personal book listings
- **Edit Books**: Update book information and images
- **Delete Books**: Remove books from listings
- **Book Conditions**: New, Like New, Good, Used categories

### 🔍 Browse & Search
- **Browse All Books**: View all available books from other users
- **Search Functionality**: Search by book title or author
- **Filter by Condition**: Filter books by their condition
- **Book Details**: Detailed view of each book with owner information
- **Real-time Updates**: Live updates when new books are added

### 🔄 Swap System
- **Request Swaps**: Send swap requests to book owners
- **Manage Offers**: View received and sent swap requests
- **Accept/Reject**: Book owners can accept or reject swap requests
- **Swap Status Tracking**: Track status of all swap requests
- **Book Availability**: Automatic availability management

### 💬 Chat System
- **Real-time Messaging**: Chat with other users after swap acceptance
- **Chat Rooms**: Dedicated chat rooms for each swap
- **Message History**: Persistent message storage
- **User-friendly Interface**: Modern chat UI with message bubbles

### ⚙️ Settings & Profile
- **User Profile**: Display user information and verification status
- **Notification Settings**: Configure email and push notifications
- **Help & Support**: Comprehensive help guide for users
- **About & Privacy**: App information and privacy policy
- **Sign Out**: Secure logout functionality

## 🛠️ Technical Implementation

### Frontend (Flutter)
- **State Management**: Provider pattern for reactive UI
- **Navigation**: Bottom navigation with 5 main screens
- **UI/UX**: Material Design 3 with custom styling
- **Image Handling**: Image picker with web/mobile compatibility
- **Form Validation**: Comprehensive input validation
- **Error Handling**: User-friendly error messages

### Backend (Firebase)
- **Authentication**: Firebase Auth for user management
- **Database**: Cloud Firestore for real-time data
- **Storage**: Firebase Storage for book images
- **Security Rules**: Proper Firestore and Storage security rules
- **Real-time Updates**: Live data synchronization

### Key Screens
1. **Welcome Screen**: App introduction and navigation to auth
2. **Login/Signup**: Authentication forms with validation
3. **Browse Books**: Main discovery screen with search/filter
4. **My Books**: Personal book management
5. **Swap Offers**: Manage incoming and outgoing swap requests
6. **Chat**: Real-time messaging system
7. **Settings**: User preferences and app information
8. **Help**: User guide and tips

## 📁 Project Structure
```
lib/
├── models/          # Data models (Book, User, Swap, Chat)
├── providers/       # State management (Auth, Book, Swap, Chat)
├── services/        # Firebase services
├── screens/         # UI screens organized by feature
├── widgets/         # Reusable UI components
├── utils/           # Constants and utilities
└── main.dart        # App entry point
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.35.3+)
- Firebase project with Authentication, Firestore, and Storage enabled
- Android Studio or VS Code with Flutter extensions

### Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Enable Cloud Firestore
4. Enable Firebase Storage
5. Configure security rules (provided in project)

### Running the App
```bash
# Navigate to project directory
cd book_swap

# Get dependencies
flutter pub get

# Run on web (recommended for testing)
flutter run -d chrome

# Run on mobile device
flutter run
```

## 🚀 Key Features Highlights

### User Experience
- **Intuitive Navigation**: Easy-to-use bottom navigation
- **Visual Feedback**: Loading states, success/error messages
- **Responsive Design**: Works on different screen sizes
- **Offline Handling**: Graceful handling of network issues

### Security & Privacy
- **Secure Authentication**: Firebase Auth integration
- **Data Protection**: Proper Firestore security rules
- **User Privacy**: Users only see necessary information
- **Safe Communication**: Moderated chat system

### Performance
- **Efficient Loading**: Optimized data fetching
- **Image Optimization**: Compressed image uploads
- **Real-time Updates**: Live data synchronization
- **Memory Management**: Proper resource cleanup

## 📊 Database Schema

### Books Collection
- title, author, condition, imageUrl
- ownerId, ownerName, createdAt
- isAvailable (for swap management)

### Swaps Collection
- requesterId, ownerId, bookId
- status (pending, accepted, rejected, completed)
- timestamps for tracking

### Chat Rooms & Messages
- participants, swapId
- messages with sender info and timestamps

## 🎯 Future Enhancements
- Push notifications for swap requests
- Location-based book discovery
- Book condition verification system
- Rating and review system
- Advanced search filters
- Social features (friends, favorites)

## 📱 Supported Platforms
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Android (API 21+)
- ✅ iOS (iOS 11+)

## 🔒 Security Features
- Email verification required
- Secure password requirements
- Protected API endpoints
- User data encryption
- Safe image uploads

This BookSwap app provides a complete, production-ready solution for book exchange with modern UI, real-time features, and robust security.