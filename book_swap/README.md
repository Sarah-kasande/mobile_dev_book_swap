# BookSwap - Mobile Book Exchange App

A comprehensive Flutter mobile application that enables students to exchange textbooks with each other, featuring real-time messaging, swap management, and modern UI design.

## 🚀 Features

### 🔐 Authentication
- **Firebase Authentication** with email/password
- **Email Verification** enforcement for security
- **User Profile Management** with display names
- **Secure Session Management** with persistent login

### 📚 Book Management (CRUD)
- **Create**: Add books with title, author, condition, and images
- **Read**: Browse all available books in a shared feed
- **Update**: Edit your own book listings
- **Delete**: Remove books from your listings
- **Image Upload**: Base64 encoding for universal compatibility

### 🔄 Swap System
- **Request Swaps**: Send swap offers to book owners
- **Real-time Updates**: Instant status changes (Pending, Accepted, Rejected)
- **Swap Management**: View sent and received offers
- **State Synchronization**: Both users see updates immediately

### 💬 Chat System
- **Real-time Messaging**: Chat after swap acceptance
- **Message Persistence**: All messages stored in Firestore
- **User-friendly UI**: Modern chat interface with timestamps

### 🎨 Modern UI/UX
- **Material Design 3**: Latest design principles
- **Gradient Cards**: Beautiful book cards with shadows
- **Responsive Design**: Works on all screen sizes
- **Smooth Animations**: Loading states and transitions

## 🏗️ Architecture

### State Management
- **Provider Pattern**: Reactive state management throughout the app
- **Clean Architecture**: Separation of concerns with proper folder structure
- **Real-time Updates**: Firestore streams for live data synchronization

### Folder Structure
```
lib/
├── models/          # Data models (Book, User, Swap, Chat)
├── providers/       # State management (Auth, Book, Swap, Chat)
├── services/        # Firebase services and API calls
├── screens/         # UI screens organized by feature
│   ├── auth/        # Authentication screens
│   ├── listings/    # Book management screens
│   ├── swap/        # Swap management screens
│   ├── chat/        # Chat screens
│   ├── settings/    # Settings and profile screens
│   └── home/        # Main navigation screen
├── widgets/         # Reusable UI components
├── utils/           # Constants and utilities
└── main.dart        # App entry point
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.35.3+)
- Firebase project with Authentication, Firestore enabled
- Android Studio or VS Code with Flutter extensions

### Firebase Configuration
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Enable Cloud Firestore
4. Add your app to Firebase project
5. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
   - Web configuration in `firebase_options.dart`

### Installation
```bash
# Clone the repository
git clone [your-repo-url]
cd book_swap

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Rules
The app uses simplified Firestore rules for development:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📱 Supported Platforms
- ✅ **Android**: API 21+ (Android 5.0+)
- ✅ **iOS**: iOS 11+
- ✅ **Web**: Chrome, Firefox, Safari, Edge

## 🎯 Key Technologies

### Frontend
- **Flutter**: Cross-platform mobile framework
- **Provider**: State management solution
- **Material Design 3**: Modern UI components

### Backend
- **Firebase Auth**: User authentication
- **Cloud Firestore**: Real-time database
- **Firebase Storage**: File storage (optional)

### Image Handling
- **Base64 Encoding**: Universal image compatibility
- **Image Compression**: Optimized for mobile
- **Web + Mobile Support**: Same code works everywhere

## 🔧 Development Features

### Code Quality
- **Dart Analyzer**: Zero warnings maintained
- **Clean Code**: Well-structured and documented
- **Error Handling**: Comprehensive error management
- **Performance**: Optimized for smooth operation

### Testing
- **Manual Testing**: Comprehensive test scenarios
- **Real-time Validation**: Live Firebase console monitoring
- **Cross-platform Testing**: Web and mobile validation

## 📊 Database Schema

### Collections
- **users**: User profile information
- **books**: Book listings with metadata
- **swaps**: Swap requests and status
- **chatRooms**: Chat room metadata
- **messages**: Individual chat messages

### Data Models
```dart
// Book Model
{
  'title': String,
  'author': String,
  'condition': int, // enum index
  'imageBase64': String?, // optional image
  'ownerId': String,
  'ownerName': String,
  'createdAt': int, // timestamp
  'isAvailable': bool
}

// Swap Model
{
  'requesterId': String,
  'ownerId': String,
  'bookId': String,
  'status': int, // enum index
  'createdAt': int,
  'updatedAt': int?
}
```

## 🚀 Deployment

### Build Commands
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📝 Assignment Compliance

This project meets all rubric requirements:
- ✅ **Authentication**: Firebase Auth with email verification
- ✅ **CRUD Operations**: Complete book management
- ✅ **State Management**: Provider pattern implementation
- ✅ **Swap Functionality**: Real-time swap system
- ✅ **Navigation**: Bottom navigation with 5 screens
- ✅ **Chat System**: Real-time messaging
- ✅ **Modern UI**: Professional design implementation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is created for educational purposes as part of a mobile development course.

## 📞 Support

For questions or issues, please refer to the project documentation or contact the development team.

---

**Built with ❤️ using Flutter and Firebase**