#!/bin/bash

# Migration script for AppColors to ColorTokens
# This script migrates a single Dart file

FILE=$1

if [ -z "$FILE" ]; then
    echo "Usage: $0 <dart_file>"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

echo "Migrating: $FILE"

# Check if already has colorTokens import
if ! grep -q "color_tokens_extension.dart" "$FILE"; then
    # Add import after other core imports
    sed -i "/import '.*\/core\/.*\.dart';$/a import '../../core/theme/color_tokens_extension.dart';" "$FILE"
    # Clean up double slashes if needed
    sed -i "s|///|../|g" "$FILE"  # This line removes accidental triple slashes
fi

# Find the build method and add colors initialization
# This is more complex, we need to find "Widget build(BuildContext context) {" and add the colors line after it
awk '
/Widget build\(BuildContext context\) \{/ {
    if (!found_build) {
        print $0
        getline
        if ($0 !~ /final colors = context\.colorTokens;/) {
            print "    final colors = context.colorTokens;"
        }
        print $0
        found_build = 1
        next
    }
}
1
' "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"

# Replace all AppColors references
sed -i 's/AppColors\.textTertiary/colors.textTertiary/g' "$FILE"
sed -i 's/AppColors\.textSecondary/colors.textSecondary/g' "$FILE"
sed -i 's/AppColors\.textPrimary/colors.textPrimary/g' "$FILE"
sed -i 's/AppColors\.textOnPrimary/colors.textOnPrimary/g' "$FILE"
sed -i 's/AppColors\.border/colors.border/g' "$FILE"
sed -i 's/AppColors\.shadow/colors.shadow/g' "$FILE"
sed -i 's/AppColors\.primary/colors.primary/g' "$FILE"
sed -i 's/AppColors\.primaryLight/colors.primaryLight/g' "$FILE"
sed -i 's/AppColors\.primaryDark/colors.primaryDark/g' "$FILE"
sed -i 's/AppColors\.secondary/colors.secondary/g' "$FILE"
sed -i 's/AppColors\.secondaryLight/colors.secondaryLight/g' "$FILE"
sed -i 's/AppColors\.background/colors.background/g' "$FILE"
sed -i 's/AppColors\.surface/colors.surface/g' "$FILE"
sed -i 's/AppColors\.surfaceVariant/colors.surfaceVariant/g' "$FILE"
sed -i 's/AppColors\.divider/colors.divider/g' "$FILE"
sed -i 's/AppColors\.error/colors.error/g' "$FILE"
sed -i 's/AppColors\.warning/colors.warning/g' "$FILE"
sed -i 's/AppColors\.success/colors.success/g' "$FILE"
sed -i 's/AppColors\.info/colors.info/g' "$FILE"
sed -i 's/AppColors\.categoryFood/colors.categoryFood/g' "$FILE"
sed -i 's/AppColors\.categoryMedical/colors.categoryMedical/g' "$FILE"
sed -i 's/AppColors\.categoryGrooming/colors.categoryGrooming/g' "$FILE"
sed -i 's/AppColors\.categoryToys/colors.categoryToys/g' "$FILE"
sed -i 's/AppColors\.categoryOther/colors.categoryOther/g' "$FILE"

echo "Migration complete for: $FILE"
