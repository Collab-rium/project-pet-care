# TODO List - Project Pet Care

## Overview
This document tracks all work items needed to complete the Pet Care app. Items are categorized by priority and phase.

**Total Items**: 16  
**Status**: Most items in Phase 1 (Logging/Error Capture) and Phase 2 (Dark Mode)

---

## Phase 1: Error Capture & Logging Enhancement ⚡

### Priority: CRITICAL - Do These First

#### 1. **Enhance Logging to Catch Asset/File Errors** ✅ (IN PROGRESS)
- **Status**: In Progress
- **What**: Add comprehensive error handling around Image.asset() and file operations
- **Why**: User reported PNG asset errors not being logged; logging system needs to catch framework-level errors
- **Done**:
  - ✅ Added FlutterError.onError handler in main.dart
  - ✅ Added PlatformDispatcher.instance.onError for async errors
  - ✅ Enhanced wallpaper_customization_screen with error logging
  - ✅ Added _buildImageProvider with error handling
  - ✅ Logs all asset loading failures to file
- **Remaining**: Test that errors are actually logged to ~/...pet_care_logs/current.log

#### 2. **Fix Missing Wallpaper Assets** ⏳
- **Status**: Pending (need to verify)
- **What**: Ensure assets/wallpapers/*.png files exist:
  - gradient_blue.png
  - pet_pattern.png
  - minimalist.png
- **Why**: App tries to load these but they may not exist, causing errors
- **How**: Check if files exist in assets/; if not, create placeholders or disable wallpaper selection
- **Effort**: 30 mins

#### 3. **Verify Logging System Captures All Errors** ⏳
- **Status**: Pending
- **What**: Test that all errors appearing in console/GUI are logged to files
- **How**:
  1. Run: `flutter run -d linux`
  2. Trigger errors (open wallpaper, change theme, etc.)
  3. Check: `tail ~/...pet_care_logs/current.log`
  4. Verify errors appear in both GUI floating button AND file
- **Effort**: 1-2 hours

#### 4. **Test Error Logging in All Screens** ⏳
- **Status**: Pending
- **What**: Add logging to all major screens for error capture
- **Where**: Budget, PetSearch, Account, ExpenseTracking, TaskReminder screens
- **How**: Wrap _loadData(), fetch operations in try-catch with FileLoggerService
- **Effort**: 2-3 hours

---

## Phase 2: Dark Mode & Theme System 🎨

### Priority: HIGH - Core User Experience

#### 5. **Fix SearchBar Dark Mode** ⏳
- **Status**: Pending
- **What**: Update searchbars to adapt colors in dark mode
- **Affected Screens**: PetSearchScreen, BudgetScreen, AccountScreen
- **Current Issue**: Light background remains in dark mode
- **Solution**: Use Theme.of(context).colorScheme for background
- **Reference**: app_button.dart (lines 151-180)
- **Effort**: 1-2 hours

#### 6. **Fix Page/Screen Backgrounds** ⏳
- **Status**: Pending
- **What**: Update all ~8+ screens to have dark mode backgrounds
- **Current Issue**: Background stays light in dark mode; only text turns gray
- **Root Cause**: Using hardcoded AppColors.background instead of theme
- **Solution**: Replace AppColors.background with Theme.of(context).scaffoldBackgroundColor
- **Screens**: Budget, Account, Expense, Tasks, Pets, Settings, etc.
- **Effort**: 2-3 hours

#### 7. **Fix TextField Dark Mode Colors** ⏳
- **Status**: Pending
- **What**: Update all text input fields to be visible in dark mode
- **Current Issue**: Light colored text fields in dark mode are hard to read
- **Solution**: Use Theme.of(context).colorScheme.surface for field backgrounds
- **Effort**: 1-2 hours

#### 8. **Fix Remaining Button Colors** ⏳
- **Status**: Pending (AppButton already done)
- **What**: Update 100+ buttons to use Theme.of(context)
- **Current Status**: AppButton FIXED; others still hardcoded
- **Reference Pattern**: Look at app_button.dart for correct implementation
- **Effort**: 3-4 hours

#### 9. **Fix Theme Color Bleeding** ⏳
- **Status**: Pending
- **What**: Ensure each theme shows its correct colors
- **Current Issue**: Orange (warm) appears in Cool Blue theme
- **Root Cause**: AppColors.primary = Color(0xFFFF8C42) (orange) is hardcoded for ALL themes
- **Solution**: Migrate 484+ AppColors refs to Theme.of(context).colorScheme
- **Expected After Fix**: 
  - Cool Blue theme → all blues
  - Warm theme → all oranges
  - Nature theme → all greens
- **Effort**: 4-5 hours

#### 10. **Test All Screens Dark/Light/Themes** ⏳
- **Status**: Pending
- **What**: Manual testing of every screen in all combinations
- **Matrix**: 8+ screens × 3 themes × 2 brightness modes = 48+ test cases
- **How**: Document which screens work, which need fixes
- **Effort**: 2-3 hours

---

## Phase 3: UI Polish & Bug Fixes 🐛

### Priority: MEDIUM - Visual Quality

#### 11. **Fix UI Element Overlapping** ⏳
- **Status**: Pending
- **What**: Fix visual bugs where elements overlap
- **Root Cause**: Inconsistent spacing system; no standardized padding/margins
- **Solution**: Create spacing constants, apply consistently
- **Effort**: 2-3 hours

#### 12. **Create Standardized Spacing System** ⏳
- **Status**: Pending
- **What**: Define reusable spacing constants
- **Examples**: 
  ```dart
  const spacing4 = 4.0;   // tiny
  const spacing8 = 8.0;   // small
  const spacing12 = 12.0; // medium
  const spacing16 = 16.0; // large
  ```
- **Goal**: Prevent ad-hoc margins/padding causing overlaps
- **Effort**: 1 hour

---

## Phase 4: Build & Deployment 🚀

### Priority: LOW - Non-Critical

#### 13. **Fix Android Build Gradle Error** ⏳
- **Status**: Pending (non-critical for Linux development)
- **What**: Resolve permission_handler_android plugin incompatibility
- **Error**: permission_handler_android:syncDebugLibJars fails
- **Root Cause**: Plugin version conflict with Gradle 8.14
- **Options**:
  1. Update permission_handler plugin version
  2. Downgrade Gradle version
  3. Switch to different permissions plugin
- **Effort**: 2-3 hours
- **Priority**: LOW (Linux build works; Android is secondary)

#### 14. **Test Linux Build End-to-End** ⏳
- **Status**: Pending
- **What**: Full validation of Linux build with all fixes
- **Checklist**:
  - [ ] App starts without errors
  - [ ] All screens load
  - [ ] Dark mode works
  - [ ] Themes switch correctly
  - [ ] Logs appear in GUI
  - [ ] Logs saved to files
  - [ ] No console errors
- **Effort**: 1-2 hours

---

## Reference: Fixed Issues (Completed)

### ✅ Already Done This Session
- [x] Build compilation errors (50+ import/syntax fixes)
- [x] Button theming system (AppButton)
- [x] Logging module (in-memory + file-based)
- [x] Error sharing mechanism
- [x] Enhanced main.dart with error handlers
- [x] Added logging to wallpaper screen
- [x] Project context documentation
- [x] GitHub Copilot instructions
- [x] copilot-instructions.md

---

## Summary

### By Status:
- **Pending**: 14 items (main work)
- **In Progress**: 1 item (error logging)
- **Done**: 8 items

### By Priority:
- **CRITICAL (Phase 1)**: 4 items - Error capture & logging
- **HIGH (Phase 2)**: 6 items - Dark mode & themes
- **MEDIUM (Phase 3)**: 2 items - UI polish
- **LOW (Phase 4)**: 2 items - Build & deployment

### Estimated Effort:
- **Phase 1 (Errors)**: 4-6 hours
- **Phase 2 (Dark Mode)**: 10-15 hours
- **Phase 3 (Polish)**: 5-7 hours
- **Phase 4 (Build)**: 3-5 hours
- **Total**: 22-33 hours

### Recommended Next Steps:
1. ✅ Just done: Added error handlers to main.dart and wallpaper screen
2. Next: Test if errors now appear in log files (Phase 1, item 3)
3. Then: Fix missing wallpaper assets (Phase 1, item 2)
4. Then: Start Phase 2 dark mode fixes

---

Last Updated: 2026-04-03  
Git Commits This Session: 9
