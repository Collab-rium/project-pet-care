#!/usr/bin/env python3
import sys
import re

def migrate_file(filepath):
    """Migrate a single Dart file from AppColors to ColorTokens"""
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # 1. Add import for ColorTokensExtension if not present
    if 'color_tokens_extension.dart' not in content:
        # Find the last import line for core
        lines = content.split('\n')
        last_core_import_idx = -1
        for i, line in enumerate(lines):
            if line.startswith("import '../../core/") or line.startswith('import "../core/'):
                last_core_import_idx = i
        
        if last_core_import_idx >= 0:
            lines.insert(last_core_import_idx + 1, "import '../../core/theme/color_tokens_extension.dart';")
            content = '\n'.join(lines)
    
    # 2. Add colors initialization to build methods
    # Find all "Widget build(BuildContext context) {" and add colors line
    pattern = r'(\s+Widget build\(BuildContext context\)\s*\{)'
    
    def add_colors_init(match):
        indent = match.group(0).split('Widget')[0]
        return match.group(0) + f'\n{indent}  final colors = context.colorTokens;'
    
    # But first check if colors line already exists
    lines = content.split('\n')
    i = 0
    while i < len(lines):
        if 'Widget build(BuildContext context)' in lines[i] and '{' in lines[i]:
            # Check next line
            if i + 1 < len(lines) and 'final colors = context.colorTokens;' not in lines[i + 1]:
                # Insert colors initialization
                indent = len(lines[i]) - len(lines[i].lstrip())
                lines.insert(i + 1, ' ' * (indent + 2) + 'final colors = context.colorTokens;')
                i += 2
            else:
                i += 1
        else:
            i += 1
    
    content = '\n'.join(lines)
    
    # 3. Replace all AppColors references
    replacements = {
        'AppColors.textTertiary': 'colors.textTertiary',
        'AppColors.textSecondary': 'colors.textSecondary',
        'AppColors.textPrimary': 'colors.textPrimary',
        'AppColors.textOnPrimary': 'colors.textOnPrimary',
        'AppColors.border': 'colors.border',
        'AppColors.shadow': 'colors.shadow',
        'AppColors.primary': 'colors.primary',
        'AppColors.primaryLight': 'colors.primaryLight',
        'AppColors.primaryDark': 'colors.primaryDark',
        'AppColors.secondary': 'colors.secondary',
        'AppColors.secondaryLight': 'colors.secondaryLight',
        'AppColors.background': 'colors.background',
        'AppColors.surface': 'colors.surface',
        'AppColors.surfaceVariant': 'colors.surfaceVariant',
        'AppColors.divider': 'colors.divider',
        'AppColors.error': 'colors.error',
        'AppColors.warning': 'colors.warning',
        'AppColors.success': 'colors.success',
        'AppColors.info': 'colors.info',
        'AppColors.categoryFood': 'colors.categoryFood',
        'AppColors.categoryMedical': 'colors.categoryMedical',
        'AppColors.categoryGrooming': 'colors.categoryGrooming',
        'AppColors.categoryToys': 'colors.categoryToys',
        'AppColors.categoryOther': 'colors.categoryOther',
    }
    
    for old, new in replacements.items():
        content = content.replace(old, new)
    
    # Write back if changed
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: migrate_colors.py <dart_file>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    try:
        if migrate_file(filepath):
            print(f"Migrated: {filepath}")
        else:
            print(f"No changes needed: {filepath}")
    except Exception as e:
        print(f"Error migrating {filepath}: {e}")
        sys.exit(1)
