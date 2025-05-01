# secure_note_app

🔐 Secure Note App

A cross-platform Flutter application to securely create, store, and manage notes using AES encryption. It integrates Firebase Auth, Firestore, and local encrypted storage to ensure a seamless and secure user experience — even offline.

## Getting Started

This project is a starting point for a Flutter application.

✨ Features

🔑 AES-256 encryption for all saved notes
📁 Local encrypted storage (secure_notes.json) using encrypt, crypto, and flutter_secure_storage
☁️ Cloud sync with Firebase Auth + Cloud Firestore
🔍 Search & 🔖 bookmark notes
📶 Offline support (cached notes visible even without Internet)
🔐 Biometric authentication with local_auth
🧠 Session timeout with local_session_timeout
🎨 Beautiful UI using google_fonts, modal_bottom_sheet, and flutter_staggered_grid_view
📤 Share notes securely with share_plus
📦 File picker support

📱 Screenshots
https://prnt.sc/rEzpIvh5E3IJ
https://prnt.sc/ssytkTHZyE5c


🛠 Tech Stack

Flutter SDK: ^3.5.4

🔐 Core Packages
Package	Description
encrypt / crypto	AES-256 encryption
flutter_secure_storage	Secure key storage
firebase_auth	Authentication
cloud_firestore	Cloud storage for notes
shared_preferences	Lightweight data caching
hive / hive_flutter	Local data storage
local_auth	Biometric/face unlock
local_session_timeout	Session management
📂 Offline Mode

Notes are saved to an encrypted file: secure_notes.json
File is decrypted locally using your secret key
Offline notes are available even without a network connection
🚀 Getting Started

🔧 Prerequisites
Flutter SDK 3.5.4+
Firebase project set up with Auth & Firestore
🧪 Run Locally
git clone https://github.com/yourusername/secure_note_app.git
cd secure_note_app
flutter pub get
flutter run
🔑 Encryption & Security

Each note is encrypted using AES-256 before saving
Keys are stored securely using flutter_secure_storage
On app launch, biometric or session-based unlock is required
🔍 Search, Bookmark, and Share

🔖 Long press to bookmark any note
🔍 Instant search across titles and content
📤 Notes can be securely shared via native sharing