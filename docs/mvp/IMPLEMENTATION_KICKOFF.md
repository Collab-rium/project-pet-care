# Frontend Implementation - Ready to Start

**Date:** March 29, 2026  
**Status:** ✅ All questions answered, ready to begin  
**Approach:** Systematic implementation of 38 todos (22 days)

---

## ✅ Confirmed Decisions

### 1. Color Palette: Warm (Orange)
Using your existing Warm palette:
- Primary: `#FF8C42` (orange)
- Secondary: `#FFB380` (light orange)
- Accent: `#FD6B6B` (red/pink)
- Background: `#FFF9F5` (warm white)
- Text: `#2C2C2C` (dark gray)
- Success: `#52B788` (green)

### 2. Build On Existing Code
**Existing screens (keep):**
- ✅ Login/Register screens
- ✅ Pet list, detail, add screens
- ✅ Reminders screen, add reminder
- ✅ Dashboard screen
- ✅ Auth gate, home screen

**New additions:**
- Design system constants (colors, text styles, spacing)
- Component library (atoms, molecules, organisms)
- Missing screens (weight tracking, expenses, budget, gallery, settings)
- Critical features (compression, warnings, permissions)
- Polish (empty states, loading, animations, accessibility)

### 3. SQLite with Seed Data
**Implementation:**
- Add `sqflite` package
- Create database schema (users, pets, reminders, weights, expenses, photos, settings)
- Seed database with sample data
- Database service layer (CRUD operations)
- Match production schema from APP_SPEC.md

### 4. All Critical Features from Day 1
**Must implement:**
- ✅ Photo compression (resize to 1920px, 80% quality, generate thumbnails)
- ✅ Storage warnings (track usage, alert at 50MB/100MB)
- ✅ Notification permissions (explain why, handle denial)

### 5. Focus: Usable, Pretty, Great UX
**Quality standards:**
- Clean, intuitive interfaces
- Smooth animations (200-300ms transitions)
- Clear feedback for all actions (success/error toasts)
- Accessible (screen reader, font scaling, contrast)
- Easy to understand (no confusing UI patterns)
- Production-quality polish

---

## 📦 Additional Dependencies Needed

Add to `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies...
  
  # Database
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3
  
  # Image processing
  image: ^4.1.3  # For compression and resizing
  
  # Charts
  fl_chart: ^0.65.0  # For weight/budget charts
  
  # File picker
  file_picker: ^6.1.1  # For backup/restore
  
  # Permissions
  permission_handler: ^11.1.0  # For notification permissions
```

---

## 🗂️ New Folder Structure

Extend existing structure:

```
lib/
├── main.dart (existing)
├── core/  (NEW - design system)
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── text_styles.dart
│   │   ├── spacing.dart
│   │   └── app_constants.dart
│   ├── utils/
│   │   ├── image_compression.dart
│   │   ├── storage_tracker.dart
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── theme/
│       ├── light_theme.dart
│       └── dark_theme.dart
├── components/ (NEW - organized component library)
│   ├── atoms/
│   │   ├── app_button.dart
│   │   ├── app_input.dart
│   │   ├── app_dropdown.dart
│   │   ├── app_toggle.dart
│   │   ├── app_badge.dart
│   │   ├── app_avatar.dart
│   │   └── app_icon.dart
│   ├── molecules/
│   │   ├── app_card.dart
│   │   ├── form_field.dart
│   │   ├── search_bar.dart
│   │   ├── stat_card.dart
│   │   ├── list_item.dart
│   │   └── empty_state.dart
│   ├── organisms/
│   │   ├── pet_profile_card.dart
│   │   ├── feature_grid.dart
│   │   ├── timeline_item.dart
│   │   ├── chart_card.dart
│   │   ├── app_modal.dart
│   │   ├── bottom_sheet.dart
│   │   └── bottom_nav_bar.dart
│   └── navbar.dart (existing - will refactor)
├── screens/ (existing - will add more)
│   ├── auth/ (existing)
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── pets/ (existing - will enhance)
│   │   ├── pet_list_screen.dart
│   │   ├── pet_detail_screen.dart
│   │   └── add_pet_screen.dart
│   ├── weights/ (NEW)
│   │   ├── weight_list_screen.dart
│   │   └── weight_chart_screen.dart
│   ├── reminders/ (existing - will enhance)
│   │   ├── reminders_screen.dart
│   │   └── add_reminder_screen.dart
│   ├── expenses/ (NEW)
│   │   ├── expense_list_screen.dart
│   │   └── expense_form_screen.dart
│   ├── budget/ (NEW)
│   │   └── budget_dashboard_screen.dart
│   ├── gallery/ (NEW)
│   │   └── photo_gallery_screen.dart
│   ├── settings/ (NEW)
│   │   ├── settings_screen.dart
│   │   ├── theme_selector_screen.dart
│   │   ├── wallpaper_screen.dart
│   │   └── backup_restore_screen.dart
│   ├── onboarding/ (NEW - defer to end)
│   │   └── onboarding_screen.dart
│   ├── dashboard_screen.dart (existing)
│   └── home_screen.dart (existing)
├── services/ (existing - will add database)
│   ├── api_service.dart (existing)
│   ├── auth_service.dart (existing)
│   ├── notification_service.dart (existing)
│   ├── database_service.dart (NEW)
│   ├── storage_service.dart (NEW - track usage)
│   └── backup_service.dart (NEW)
├── models/ (existing - will add more)
│   ├── user.dart (existing)
│   ├── pet.dart (existing)
│   ├── reminder.dart (existing)
│   ├── weight.dart (NEW)
│   ├── expense.dart (NEW)
│   ├── budget.dart (NEW)
│   ├── photo.dart (NEW)
│   └── settings.dart (NEW)
└── config/ (existing)
    └── api_config.dart (existing)
```

---

## 🚀 Implementation Order (First Week)

### **Day 1: Design System Foundation**

**Morning:**
1. ✅ Update `pubspec.yaml` with new dependencies
2. ✅ Run `flutter pub get`
3. ✅ Create `lib/core/constants/colors.dart` (Warm palette)
4. ✅ Create `lib/core/constants/text_styles.dart` (Poppins + Inter)
5. ✅ Create `lib/core/constants/spacing.dart` (8px base unit)

**Afternoon:**
6. ✅ Create `lib/core/theme/light_theme.dart` (using Warm colors)
7. ✅ Create `lib/core/theme/dark_theme.dart` (dark mode adaptation)
8. ✅ Update `main.dart` to use new themes
9. ✅ Create `lib/core/utils/image_compression.dart`

**Deliverable:** Design system constants + themes + compression utility

---

### **Day 2: Atomic Components**

**Tasks:**
1. ✅ Create `lib/components/atoms/app_button.dart`
   - Primary, secondary, icon, FAB variants
   - Use Warm colors
   - Hover/press states
2. ✅ Create `lib/components/atoms/app_input.dart`
   - Text, number, multiline
   - Validation states
3. ✅ Create `lib/components/atoms/app_dropdown.dart`
4. ✅ Create `lib/components/atoms/app_toggle.dart` (switch, checkbox, radio)
5. ✅ Create `lib/components/atoms/app_badge.dart`
6. ✅ Create `lib/components/atoms/app_avatar.dart`

**Deliverable:** Complete atomic component library

---

### **Day 3: Molecule Components**

**Tasks:**
1. ✅ Create `lib/components/molecules/app_card.dart`
2. ✅ Create `lib/components/molecules/form_field.dart` (label + input + error)
3. ✅ Create `lib/components/molecules/search_bar.dart`
4. ✅ Create `lib/components/molecules/stat_card.dart` (for dashboard)
5. ✅ Create `lib/components/molecules/list_item.dart`
6. ✅ Create `lib/components/molecules/empty_state.dart`

**Deliverable:** Molecule component library

---

### **Day 4: Organism Components + Navigation**

**Morning:**
1. ✅ Create `lib/components/organisms/pet_profile_card.dart`
2. ✅ Create `lib/components/organisms/chart_card.dart` (wrapper for fl_chart)
3. ✅ Create `lib/components/organisms/app_modal.dart`
4. ✅ Create `lib/components/organisms/bottom_nav_bar.dart`

**Afternoon:**
5. ✅ Set up routing (named routes for all screens)
6. ✅ Update existing navbar to use new design system
7. ✅ Create pet context provider (for pet switching)

**Deliverable:** Organism components + navigation working

---

### **Day 5: Database Setup**

**Tasks:**
1. ✅ Create `lib/services/database_service.dart`
   - SQLite initialization
   - Schema creation (users, pets, reminders, weights, expenses, photos, settings)
2. ✅ Create seed data (sample pets, reminders, weights)
3. ✅ Create CRUD methods for each table
4. ✅ Test database operations
5. ✅ Create `lib/services/storage_service.dart` (track storage usage)

**Deliverable:** Working SQLite database with seed data

---

## 📝 Implementation Notes

### Photo Compression Strategy
```dart
// lib/core/utils/image_compression.dart
import 'package:image/image.dart' as img;

class ImageCompression {
  static Future<File> compressImage(File imageFile) async {
    // Read image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Failed to decode image');
    
    // Resize to max 1920px width
    final resized = image.width > 1920
        ? img.copyResize(image, width: 1920)
        : image;
    
    // Compress to 80% JPEG quality
    final compressed = img.encodeJpg(resized, quality: 80);
    
    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressed);
    
    return tempFile;
  }
  
  static Future<File> createThumbnail(File imageFile, {int size = 200}) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Failed to decode image');
    
    final thumbnail = img.copyResize(image, width: size, height: size);
    final compressed = img.encodeJpg(thumbnail, quality: 85);
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressed);
    
    return tempFile;
  }
}
```

### Storage Warning Strategy
```dart
// lib/services/storage_service.dart
class StorageService {
  static const int WARNING_THRESHOLD_MB = 50;
  static const int CRITICAL_THRESHOLD_MB = 100;
  
  Future<StorageInfo> getStorageInfo() async {
    final dbPath = await getDatabasesPath();
    final dbFile = File('$dbPath/pet_care.db');
    final dbSize = await dbFile.length();
    
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/photos');
    
    int photosSize = 0;
    if (await photosDir.exists()) {
      await for (var file in photosDir.list(recursive: true)) {
        if (file is File) {
          photosSize += await file.length();
        }
      }
    }
    
    final totalBytes = dbSize + photosSize;
    final totalMB = totalBytes / (1024 * 1024);
    
    return StorageInfo(
      databaseMB: dbSize / (1024 * 1024),
      photosMB: photosSize / (1024 * 1024),
      totalMB: totalMB,
      needsWarning: totalMB > WARNING_THRESHOLD_MB,
      isCritical: totalMB > CRITICAL_THRESHOLD_MB,
    );
  }
  
  void checkAndShowWarning(BuildContext context) async {
    final info = await getStorageInfo();
    
    if (info.isCritical) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('⚠️ Storage Critical'),
          content: Text(
            'Storage usage is high (${info.totalMB.toStringAsFixed(1)} MB).\n\n'
            'Consider deleting old photos or exporting data.'
          ),
          actions: [
            TextButton(
              child: Text('Manage Storage'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/gallery');
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else if (info.needsWarning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Storage: ${info.totalMB.toStringAsFixed(1)} MB used'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ),
      );
    }
  }
}
```

---

## ✅ Ready to Start

**First task:** `fe-fonts` - Create text styles with Poppins + Inter

**Command to start:**
```bash
cd /home/arslan/.openclaw/workspace/project-pet-care/frontend
```

**Would you like me to:**
1. Start implementing Day 1 tasks now?
2. Create a detailed breakdown for a specific todo?
3. Answer any other questions first?

Let me know and I'll begin! 🚀
