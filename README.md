## 🚀 Getting Started

This guide helps you set up Flutter, Android Studio, and run the VeriLock mobile app on your device.

---

## 📦 1. Install Flutter SDK
Download Flutter from the official website:

🔗 https://docs.flutter.dev/get-started/install

After installation, run:

```sh
flutter doctor
```

Make sure there are **no errors** in:
- Flutter SDK  
- Android toolchain  
- Android licenses  
- Connected device  

---

## 💻 2. Install Android Studio
Download Android Studio here:

🔗 https://developer.android.com/studio

During installation be sure to install:
- Android SDK
- Android SDK Platform Tools
- Android Emulator (optional)
- Android Virtual Device (AVD)

---

## 🧩 3. Clone the repository

```sh
git clone https://github.com/YOUR_USERNAME/verilock-mobile-app.git
cd verilock-mobile-app
```

---

## 📦 4. Install dependencies

```sh
flutter pub get
```

---

## 🔐 5. Setup Environment Variables

Create a `.env` file in the **root** of the project:

```
API_BASE_URL=http://YOUR_RPI_IP:8000
```

(Example: `http://192.168.1.25:8000`)

---

## ▶️ 6. Run the app

### Android (Physical Device)
Enable:
- Developer Options  
- USB Debugging  

Then run:

```sh
flutter run
```

### Android Emulator
You may use:
- Pixel 6 (Recommended)
- API Level 33+

Then run:

```sh
flutter run
```

---

## 📡 Backend Required

This app **requires the VeriLock Python Backend** running on the Raspberry Pi.

Backend repo:  
🔗 https://github.com/YOUR_BACKEND_REPO_HERE

Make sure:
- The backend is reachable on the same WiFi network  
- The IP matches your `.env` file  
- Ports 8000 and camera stream port are open  

---

## 🛠 Common Commands

```sh
flutter clean          # Clear build cache
flutter pub get        # Fetch dependencies
flutter build apk      # Build Android APK
flutter run            # Run on device
```

---

## ✔️ You’re ready!

You can now connect your Flutter app to your Raspberry Pi and unlock your door using 2FA (Face + Voice).
