# Quick Editing Guide

## Where to Find Things

### 1. TO CHANGE MAIN APP COLOR
**File:** `lib/core/theme/app_theme_config.dart`
**Line:** ~35 (look for `PRIMARY COLOR` section)
**Change:** `static const Color primaryColor = Color(0xFFFF8C42);`

**Color Examples:**
- Orange: `Color(0xFFFF8C42)`
- Blue: `Color(0xFF2196F3)`
- Green: `Color(0xFF4CAF50)`
- Purple: `Color(0xFF9C27B0)`
- Pink: `Color(0xFFE91E63)`

---

### 2. TO CHANGE BACKGROUND COLOR (Light Mode)
**File:** `lib/core/theme/app_theme_config.dart`
**Line:** ~45 (look for `LIGHT MODE COLORS`)
**Change:** `static const Color lightBackground = Color(0xFFFFF9F5);`

---

### 3. TO CHANGE CARD/SURFACE COLOR
**File:** `lib/core/theme/app_theme_config.dart`
**Line:** ~46
**Change:** `static const Color lightSurface = Colors.white;`

---

### 4. TO CHANGE TEXT SIZES
**File:** `lib/core/theme/app_theme_config.dart`
**Line:** ~75 (look for `TEXT STYLES` section)

**Sizes:**
- `fontSizeH1 = 28.0` - Biggest headings
- `fontSizeH2 = 22.0` - Section headings
- `fontSizeH3 = 18.0` - Card titles
- `fontSizeBody = 14.0` - Normal text
- `fontSizeSmall = 12.0` - Small text

---

### 5. TO CHANGE SPACING/PADDING
**File:** `lib/core/theme/app_theme_config.dart`
**Line:** ~95 (look for `SPACING` section)

**Values:**
- `spacingSm = 8.0` - Small gaps
- `spacingMd = 16.0` - Medium gaps
- `spacingLg = 24.0` - Large gaps

---

### 6. TO CHANGE DARK MODE COLORS
**File:** `lib/core/theme/app_theme_config.dart`
**Line:** ~55 (look for `DARK MODE COLORS` section)

**Colors:**
- `darkBackground = Color(0xFF1A1A1A)` - Dark background
- `darkSurface = Color(0xFF2C2C2C)` - Dark cards

---

## Quick Tips

### Color Format
Use `Color(0xFFRRGGBB)` where:
- `FF` = full opacity (always use FF)
- `RR` = red (00 to FF)
- `GG` = green (00 to FF)
- `BB` = blue (00 to FF)

**Example:** `Color(0xFFFF8C42)` = orange

### Find & Replace
1. Open the file in your editor
2. Use Ctrl+F (or Cmd+F on Mac) to find the line
3. Change the value
4. Save the file
5. Restart the app to see changes

---

## File Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_theme_config.dart  ← EDIT THIS FOR ALL STYLES
│       └── theme_manager.dart     ← Don't touch (uses config above)
├── screens/
│   ├── dashboard_screen.dart      ← Home screen
│   ├── pet_list_screen.dart       ← Pets list
│   ├── budget_screen.dart         ← Budget screen
│   └── account_screen.dart        ← Account screen
└── main.dart                      ← App entry point
```

---

## Common Changes

### "I want blue theme instead of orange"
1. Open `app_theme_config.dart`
2. Find line ~35
3. Change `Color(0xFFFF8C42)` to `Color(0xFF2196F3)`
4. Save and restart app

### "I want darker background"
1. Open `app_theme_config.dart`
2. Find line ~45
3. Change `Color(0xFFFFF9F5)` to something like `Color(0xFFF0F0F0)`
4. Save and restart app

### "Text is too small/big"
1. Open `app_theme_config.dart`
2. Find line ~75
3. Adjust the numbers (bigger = larger text)
4. Save and restart app

---

## Need Help?

If something breaks:
1. Check for typos in color codes
2. Make sure you have the right number of zeros/letters
3. Don't delete commas or semicolons
4. Restart the app after changes
