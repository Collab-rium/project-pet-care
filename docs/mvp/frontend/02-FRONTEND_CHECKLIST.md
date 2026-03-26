# Frontend Implementation Checklist — Project Pet Care MVP

**For**: Frontend Developer  
**What**: Build Flutter UI screens with mock API  
**Timeline**: Days 1-10 (Phase 0-3)

---

## Table of Contents

1. [Phase 0: Setup](#phase-0-setup-days-1-2)
2. [Phase 1: Mock API & Screens](#phase-1-frontend-mock-api--screens-days-3-7)
3. [Phase 2: Testing](#phase-1-frontend-mock-api--screens-days-3-7)
4. [Phase 3: Integration](#phase-3-integration-testing-days-8-10)
5. [Checkpoint Summary](#checkpoints)

---

## Phase 0: Setup (Days 1-2)

### Prerequisites

- [ ] Flutter 3+ installed
- [ ] Dart 2.17+ available
- [ ] Verify: `flutter --version` outputs 3.x+
- [ ] Android emulator or iOS simulator available

### Project Structure

- [ ] Navigate to `frontend/` directory
- [ ] Verify `pubspec.yaml` exists with dependencies:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    firebase_core: ^2.11.0
    cloud_firestore: ^4.8.0
    firebase_auth: ^4.6.0
    http: ^1.0.0
    image_picker: ^1.0.0
    palette_generator: ^0.3.0
    shared_preferences: ^2.1.0
    flutter_secure_storage: ^8.0.0
  ```
- [ ] Run: `flutter pub get`
- [ ] **Checkpoint**: Flutter project generates without errors

### API Contract Review

- [ ] Open `docs/mvp/01-API_CONTRACT.md`
- [ ] Read all endpoint URLs, request/response JSON shapes
- [ ] Note: Auth uses `Authorization: Bearer <jwt>` header (JWT issued by backend)
- [ ] Note: All responses wrapped in `{ data: ... }` or `{ error: ... }`
- [ ] **Sign off**: You understand contract and will build UI to match

### Project Folders

- [ ] Create `frontend/lib/screens/` (UI screens)
- [ ] Create `frontend/lib/services/` (API layer)
- [ ] Create `frontend/lib/models/` (data models)
- [ ] Create `frontend/lib/config/` (configuration)
- [ ] Create `frontend/lib/components/` (reusable widgets)
- [ ] Create `frontend/lib/utils/` (helpers)

---

## Phase 1: Frontend Mock API & Screens (Days 3-7)

### Data Models

- [ ] Create `frontend/lib/models/user.dart`:
  ```dart
  class User {
    final String id;
    final String email;
    final String name;
    final DateTime createdAt;
    
    User({required this.id, required this.email, required this.name, required this.createdAt});
    factory User.fromJson(Map json) => User(...)
  }
  ```
- [ ] Create `frontend/lib/models/pet.dart`:
  ```dart
  class Pet {
    final String id;
    final String ownerId;
    final String name;
    final String type;  // dog, cat, bird, other
    final int age;
    final String breed;
    final String? photoUrl;
    final DateTime createdAt;
    
    Pet({required this.id, ...});
    factory Pet.fromJson(Map json) => Pet(...)
  }
  ```
- [ ] Create `frontend/lib/models/reminder.dart`:
  ```dart
  class Reminder {
    final String id;
    final String petId;
    final String userId;
    final String type;  // feeding, medication, vet, exercise, etc.
    final String message;
    final DateTime scheduledTime;
    final String repeat;  // daily, weekly, once
    final String status;  // pending, completed
    final DateTime createdAt;
    
    Reminder({required this.id, ...});
    factory Reminder.fromJson(Map json) => Reminder(...)
  }
  ```

### Mock API Service

- [ ] Create `frontend/lib/config/api_config.dart`:
  ```dart
  const String API_BASE_URL = 'http://localhost:4000';
  // For Android emulator (10.0.2.2 is localhost inside Android)
  // const String API_BASE_URL = 'http://10.0.2.2:4000';
  
  const bool USE_MOCK_API = true;  // Set to false to use real backend
  ```
- [ ] Create `frontend/lib/services/api_service.dart` (abstract interface):
  ```dart
  abstract class ApiService {
    Future<Map<String, dynamic>> register(String email, String password, String name);
    Future<Map<String, dynamic>> login(String email, String password);
    Future<List<Pet>> getPets();
    Future<Pet> createPet(Map<String, dynamic> petData);
    Future<Pet> updatePet(String petId, Map<String, dynamic> data);
    Future<void> deletePet(String petId);
    Future<List<Reminder>> getReminders({String? petId});
    Future<Reminder> createReminder(Map<String, dynamic> reminderData);
    Future<Reminder> updateReminder(String reminderId, Map<String, dynamic> data);
    Future<void> deleteReminder(String reminderId);
    Future<Map<String, dynamic>> getDashboardToday();
  }
  ```
- [ ] Create `frontend/lib/services/mock_api_service.dart`:
  - Implement all methods from ApiService
  - Return hardcoded mock data matching contract shapes
  - Simulate network delay: `await Future.delayed(Duration(milliseconds: 500))`
  - Example:
    ```dart
    @override
    Future<List<Pet>> getPets() async {
      await Future.delayed(Duration(milliseconds: 500));
      return [
        Pet(id: 'pet-1', ownerId: 'user-1', name: 'Buddy', type: 'dog', ...),
        Pet(id: 'pet-2', ownerId: 'user-1', name: 'Whiskers', type: 'cat', ...),
      ];
    }
    ```
  - Use in-memory state for tracking logged-in user, added pets, created reminders (so UI changes persist during session)
- [ ] Create `frontend/lib/services/http_api_service.dart`:
  - Implement all methods from ApiService
  - Use `http.get()`, `http.post()`, `http.put()`, `http.delete()` to call backend
  - Add `Authorization: Bearer <jwt>` header to all requests (except /auth/register and /auth/login). Use secure storage to retrieve the JWT.
  - If the backend returns 401, clear token and show login flow.
  - Parse JSON responses
  - Convert errors to exception classes
  - Example:
    ```dart
    @override
    Future<List<Pet>> getPets() async {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/pets'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((p) => Pet.fromJson(p)).toList();
      } else {
        throw Exception('Failed to load pets');
      }
    }
    ```
- [ ] Create `frontend/lib/services/api_provider.dart` (factory):
  ```dart
  ApiService getApiService() {
    return USE_MOCK_API ? MockApiService() : HttpApiService();
  }
  ```
- [ ] **Pass Criteria**: All API methods return data in correct shape; mock API responds within 1 second

### Authentication Screens

- [ ] Create `frontend/lib/screens/login_screen.dart`:
  - Email input field
  - Password input field
  - Login button
  - "Don't have account? Register" link
  - Error message display (if login fails)
  - Loading indicator while logging in
  - On success: Save JWT to secure storage (use `flutter_secure_storage`), navigate to dashboard
- [ ] Create `frontend/lib/screens/register_screen.dart`:
  - Email input field
  - Password input field
  - Confirm password field
  - Name input field
  - Register button
  - "Already have account? Login" link
  - Validate: password >= 6 chars
  - On success: Auto-login and navigate to dashboard
- [ ] Create `frontend/lib/services/auth_service.dart`:
  - Manage token storage securely (`flutter_secure_storage`) and expose an in-memory cached token for runtime use
  - Manage current user state
  - Methods: register(), login(), logout(), getToken(), isTokenExpired()
  - Notes: Do NOT store JWTs in plain SharedPreferences. Use secure storage for tokens and clear on logout.
- [ ] Test:
  - Run app: `flutter run`
  - Register new user → dashboard should appear
  - Logout → login screen
  - Login with registered user → dashboard appears
- [ ] **Pass Criteria**: Auth flow works; token persists after app restart

### Pet List Screen

- [ ] Create `frontend/lib/screens/pet_list_screen.dart`:
  - Display list of user's pets (call `/pets`)
  - For each pet, show: photo (if exists), name, type, age, breed
  - FloatingActionButton "Add Pet"
  - Tap pet → navigate to pet detail screen
  - Pull-to-refresh to reload pet list
- [ ] Create pet card widget showing all fields nicely formatted
- [ ] Test:
  - Navigate to Pet List tab
  - Verify mock pets display
  - Pull to refresh
- [ ] **Pass Criteria**: Pet list loads and displays all fields

### Pet Detail Screen

- [ ] Create `frontend/lib/screens/pet_detail_screen.dart`:
  - Display full pet info (name, type, age, breed, photo)
  - Edit button → navigate to edit screen
  - Delete button → show confirmation dialog, delete, pop back
  - Show reminders for this pet (filter by petId)
  - Add reminder button
- [ ] Create edit functionality (same form as add, but pre-filled)
- [ ] Test:
  - Tap pet from list
  - Verify all fields display
  - Edit pet name, verify update
  - Delete pet, verify removed from list
- [ ] **Pass Criteria**: Pet detail CRUD works

### Add/Edit Pet Screen

- [ ] Create `frontend/lib/screens/add_pet_screen.dart`:
  - Form fields: name (text), type (dropdown: dog/cat/bird/other), age (number), breed (text)
  - Photo picker button (use `image_picker` package)
  - Save button
  - On save: POST to `/pets` (or PUT if editing)
  - On success: Pop and refresh pet list
  - Show validation errors
- [ ] Test:
  - Add new pet with all fields
  - Verify pet appears in list
  - Edit pet, change fields
  - Verify changes persisted
- [ ] **Pass Criteria**: Pet form works; creates/updates correctly

### Reminders Screen

- [ ] Create `frontend/lib/screens/reminders_screen.dart`:
  - List all reminders (call `/reminders`)
  - For each reminder: pet icon, message, scheduled time, type icon
  - Optional filter dropdown by pet
  - FloatingActionButton "Add Reminder"
  - Tap reminder → navigate to detail/edit
  - Swipe to delete reminder
- [ ] Create `frontend/lib/screens/add_reminder_screen.dart`:
  - Form fields: pet (dropdown), type (dropdown: feeding/medication/vet/exercise), message (text), scheduled date/time picker, repeat (dropdown: daily/weekly/once)
  - Save button
  - On save: POST to `/reminders`
- [ ] Test:
  - Add reminder for a pet
  - Verify displayed in reminders list
  - Filter by pet
  - Delete reminder
- [ ] **Pass Criteria**: Reminder CRUD works

### Dashboard Screen

- [ ] Create `frontend/lib/screens/dashboard_screen.dart`:
  - Display today's date
  - Call `/dashboard/today` endpoint
  - Show list of today's tasks with icons
  - Color-code or highlight overdue reminders (red/orange)
  - Show summary: Total | Completed | Pending | Overdue
  - Tap task to mark as completed (PUT `/reminders/{id}` with `status: completed`)
  - Refresh button to reload
- [ ] Create task card widget showing message, time, pet name, overdue indicator
- [ ] Test:
  - Navigate to dashboard
  - Verify today's reminders display
  - Verify overdue tasks highlighted
  - Tap task to mark complete
  - Verify summary counts accurate
- [ ] **Pass Criteria**: Dashboard displays correctly; overdue detection works

### Navigation & Routing

- [ ] Create bottom tab navigation (or drawer menu):
  - Tab 1: Dashboard
  - Tab 2: Pets
  - Tab 3: Reminders (or add to pet detail)
  - Settings/Account (optional for MVP)
- [ ] Implement auth gate:
  - If no token in SharedPreferences → show login screen
  - If token exists → show dashboard
- [ ] Create `frontend/lib/main.dart`:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(PetCareApp());
  }
  
  class PetCareApp extends StatelessWidget {
    build(context) {
      return MaterialApp(
        title: 'Pet Care',
        theme: ThemeData(...),
        home: AuthGate(),  // Check token and route accordingly
      );
    }
  }
  ```
- [ ] Test:
  - Cold start without token → login screen
  - Login → dashboard
  - Navigate through all tabs
  - Logout → login screen
- [ ] **Pass Criteria**: Navigation works; auth gate functional

### Dynamic Themes

- [ ] Create `frontend/lib/services/theme_service.dart`:
  - Detect dominant color from pet image using `palette_generator`
  - Generate ThemeData with primary color
  - Also theme based on pet type (e.g., dog = blue, cat = purple)
- [ ] Implement color detection:
  ```dart
  Future<Color> getDominantColor(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = 
      await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color ?? Colors.blue;
  }
  ```
- [ ] Apply theme globally in main.dart theme property
- [ ] Test:
  - Upload pet photo
  - Verify theme color changes
  - Switch pet
  - Verify theme adjusts
- [ ] **Pass Criteria**: Theme changes dynamically based on pet

### Widget & Integration Tests

- [ ] Create `test/` folder in frontend
- [ ] Write widget tests for each screen (with MockApiService):
  ```dart
  testWidgets('Login screen displays', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.byType(TextField), findsWidgets);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
  ```
- [ ] Test auth flow: Register → Login → Dashboard → navigate screens
- [ ] Test pet flow: Add → List → Edit → Delete
- [ ] Test reminder flow: Create → List → Mark complete → Delete
- [ ] Test dashboard overdue detection
- [ ] Run tests: `flutter test`
- [ ] Target coverage >= 70%

### Checkpoint 2: Frontend & Mock API Ready

- [ ] App builds without errors: `flutter run`
- [ ] Login/register flow works with mock API
- [ ] All screens implemented and navigable
- [ ] Pets, reminders, dashboard functional
- [ ] Mock API service complete and matches contract
- [ ] Widget tests pass
- [ ] Ready for backend integration

---

## Phase 2: (Happens in parallel with backend work)

**Backend team** builds endpoints while you refine UI with mock data.

- [ ] Test all screens with mock data
- [ ] Get feedback from project owner on UI/UX
- [ ] Make small UI tweaks
- [ ] Be available to clarify contract if needed

---

## Phase 3: Integration Testing (Days 8-10)

### Switch to Real Backend

- [ ] Update `frontend/lib/config/api_config.dart`:
  ```dart
  const bool USE_MOCK_API = false;  // Switch to real backend
  ```
- [ ] Verify API_BASE_URL matches backend server location
  - Local dev: `http://localhost:4000`
  - Android emulator: `http://10.0.2.2:4000`
- [ ] Run app: `flutter run`

### End-to-End Test Scenarios

**Scenario A: Fresh User Journey**
- [ ] Register new user via frontend
- [ ] Verify user created on backend
- [ ] Login with same credentials
- [ ] Dashboard loads
- [ ] Pass: Full registration flow works

**Scenario B: Pet Management**
- [ ] Add pet "Buddy"
- [ ] Upload photo for Buddy
- [ ] Verify photo displays on pet card
- [ ] Edit Buddy's age
- [ ] Verify update persisted
- [ ] Delete Buddy
- [ ] Verify removed from list
- [ ] Pass: Pet CRUD end-to-end

**Scenario C: Reminders & Dashboard**
- [ ] Create reminder "Feed Buddy" at 8am today
- [ ] Create reminder "Bath" at 6pm yesterday (so it's overdue)
- [ ] Navigate to dashboard
- [ ] Verify both reminders displayed
- [ ] Verify Bath is highlighted as overdue
- [ ] Verify summary counts correct
- [ ] Tap Bath reminder to mark complete
- [ ] Verify status updates, summary changes
- [ ] Pass: Reminder flow and dashboard logic correct

**Scenario D: Error Handling**
- [ ] Try to save pet without name
- [ ] Verify error message displays
- [ ] Pass: Validation errors handled
- [ ] Stop backend server
- [ ] Try to load pets
- [ ] Verify network error message displays gracefully
- [ ] Pass: Network errors handled

### Performance & Stability

- [ ] Load 50+ pets and reminders
- [ ] Verify no crashes
- [ ] Verify scroll performance smooth
- [ ] Monitor memory (no big leaks)
- [ ] Test on both Android and iOS emulators

### Bug Fixes & Refinement

- [ ] Document any issues found (API mismatches, UI glitches, performance)
- [ ] Work with backend dev to resolve issues
- [ ] Test fixes
- [ ] Improve error messages if needed

### Checkpoint 3: Full Stack Integration Complete

- [ ] Real backend connected
- [ ] All end-to-end scenarios pass
- [ ] No crashes or major errors
- [ ] Performance acceptable
- [ ] Error handling works
- [ ] Ready for final QA and polish

---

## Checkpoints Summary

| Checkpoint | Timing | Criteria |
|-----------|--------|----------|
| 1 (Setup) | Day 2 | Flutter project ready, pubspec.yaml, folders created |
| 2 (Screens) | Day 7 | All screens implemented, mock API ready, tests pass |
| 3 (Integration) | Day 10 | Real backend connected, end-to-end scenarios pass |

---

## Quick Reference

**Most important files**:
- `docs/mvp/01-API_CONTRACT.md` — Your spec (read often)
- `frontend/lib/main.dart` — App entry point
- `frontend/lib/services/api_service.dart` — API interface
- `frontend/lib/services/mock_api_service.dart` — Mock data
- `frontend/pubspec.yaml` — Your dependencies

**Key commands**:
- `flutter run` — Start app
- `flutter run -v` — Verbose mode (see logs)
- `flutter test` — Run widget tests
- `flutter clean && flutter pub get` — Clean and reinstall
- `flutter emulators --launch android_emulator` — Launch emulator

**Testing locally**:
- Backend at `http://localhost:4000`
- Android emulator backend at `http://10.0.2.2:4000`
