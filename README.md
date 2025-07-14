# 📋 FixIt — Maintenance Complaint Management System
FixIt is a solution for college/university maintenance management.
Students can raise complaints through a Flutter mobile app, and administrators can view, track, and resolve complaints through a React-based admin panel.

This project uses Firebase for authentication, storage, and database.
Optionally integrates with AI (Gemini API) for smarter issue categorization.

### ✨ Features
👨‍🎓 Student App (Flutter)
✅ Splash screen — checks login state
✅ Authentication — Signup/Login with Email/Password or Google
✅ Role-based access — students can raise/view only their complaints
✅ Raise a complaint — upload image, write description, submit
✅ Track complaint — view status (Pending, In Progress, Resolved)

👨‍💼 Admin Panel (React + Firebase)
✅ Authentication — Only admins can log in
✅ View all complaints (by all students)
✅ Update complaint status (Pending → In Progress → Resolved)
✅ Responsive and clean UI

### 🔗 Tech Stack
| Part                  | Tech/Service                        |
|-----------------------|-------------------------------------|
| Frontend (Student)    | Flutter                             |
| Frontend (Admin)      | React + Tailwind CSS                |
| Backend & Storage     | Firebase Firestore + Storage        |
| Authentication        | Firebase Auth                       |
| Optional AI           | Gemini API (for classification)     |

## 📱 Student App (Flutter)
- Getting Started:
  ```bash
  cd student-app
  flutter pub get
  flutter run
  ```
- Directory Structure
  ```css
  flutter_project/
  ├─ android/
  │  ├─ app/
  │  │  ├─ google-services.json
  ├─ assets/
  │  ├─ logo.png
  ├─ build/
  ├─ ios/
  ├─ lib/
  │  ├─ main.dart
  │  ├─ screens/
  │  │  ├─ splash_screen.dart
  │  │  ├─ auth_screen.dart
  │  │  ├─ dashboard_page.dart
  │  │  ├─ comaplint_form.dart
  │  │  ├─ select_location_page.dart
  ├─ linux/
  ├─ macos/
  ├─ test/
  ├─ web/
  ├─ windows/
  ├─ .flutter-plugins
  ├─ .flutter-plugins-dependencies
  ├─ .gitignore
  ├─ .metadata
  ├─ analysis_options.yaml
  ├─ fixit.iml
  ├─ pubspec.lock
  ├─ pubspec.yaml
  ```
  - Key Screens
     - SplashScreen
     - Login / Signup
     - StudentDashboard (list complaints)
     - RaiseComplaint (form to submit complaint)
