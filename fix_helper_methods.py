#!/usr/bin/env python3
"""
Fix helper methods that use colors variable but don't have access to it.
Solution: Pass colors as a parameter to these methods.
"""
import re
import sys

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    
    # Find all private method declarations that use colors
    # and all calls to them within build method
    
    lines = content.split('\n')
    
    # First find the build method to extract colors parameter
    build_idx = -1
    for i, line in enumerate(lines):
        if 'Widget build(BuildContext context)' in line:
            build_idx = i
            break
    
    if build_idx == -1:
        return False  # No build method
    
    # Find the colors initialization line
    colors_init_idx = -1
    for i in range(build_idx, min(build_idx + 10, len(lines))):
        if 'final colors = context.colorTokens;' in lines[i]:
            colors_init_idx = i
            break
    
    if colors_init_idx == -1:
        return False  # No colors initialization (skip)
    
    # Find all methods that reference colors
    methods_using_colors = {}
    in_method = False
    current_method = None
    method_indent = 0
    method_start_idx = -1
    
    for i in range(len(lines)):
        if re.match(r'\s+Widget _build\w+\(', lines[i]) or \
           re.match(r'\s+\w+ _\w+\(', lines[i]):
            # This is a private method definition
            in_method = True
            current_method = re.search(r'_\w+\(', lines[i]).group(0)[:-1]
            method_indent = len(lines[i]) - len(lines[i].lstrip())
            method_start_idx = i
            methods_using_colors[current_method] = {'start': i, 'uses_colors': False}
        
        elif in_method and 'colors.' in lines[i]:
            # This method uses colors
            if current_method in methods_using_colors:
                methods_using_colors[current_method]['uses_colors'] = True
        
        elif in_method and lines[i].lstrip().startswith('} Widget ') or \
             in_method and lines[i].lstrip().startswith('}') and \
             lines[i].lstrip() == '}':
            # End of method
            methods_using_colors[current_method]['end'] = i
            in_method = False
            current_method = None
    
    # Now fix: Add ColorTokens parameter to methods that use colors
    modified_lines = lines.copy()
    offset = 0
    
    for method_name, info in sorted(methods_using_colors.items(), key=lambda x: x[1]['start'], reverse=True):
        if not info.get('uses_colors'):
            continue
        
        start_idx = info['start'] + offset
        
        # Find the opening parenthesis
        line = modified_lines[start_idx]
        match = re.search(r'(\w+)\s*_' + re.escape(method_name) + r'\((.*?)\)', line)
        if not match:
            continue
        
        return_type = match.group(1)
        params = match.group(2)
        
        # Add ColorTokens parameter
        if params:
            new_params = params + ', ColorTokens colors'
        else:
            new_params = 'ColorTokens colors'
        
        # Update the method signature
        new_line = re.sub(
            r'(Widget|Color|TextStyle)\s+_' + re.escape(method_name) + r'\([^)]*\)',
            f'{return_type} _{method_name}({new_params})',
            line
        )
        
        modified_lines[start_idx] = new_line
    
    # Now find all calls to these methods and add colors argument
    for method_name in [m for m, info in methods_using_colors.items() if info.get('uses_colors')]:
        for i in range(len(modified_lines)):
            # Look for calls like _buildInitials() -> _buildInitials(colors)
            if f'_{method_name}(' in modified_lines[i]:
                # Make sure it's in the build method (after colors_init_idx)
                if i > colors_init_idx:
                    modified_lines[i] = re.sub(
                        f'_{method_name}\(',
                        f'_{method_name}(colors',
                        modified_lines[i]
                    )
    
    content = '\n'.join(modified_lines)
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

if __name__ == '__main__':
    files = [
        '/home/arslan/.openclaw/workspace/project-pet-care/frontend/lib/components/atoms/app_avatar.dart',
        '/home/arslan/.openclaw/workspace/project-pet-care/frontend/lib/components/atoms/app_badge.dart',
        '/home/arslan/.openclaw/workspace/project-pet-care/frontend/lib/components/organisms/notification_permission.dart',
        '/home/arslan/.openclaw/workspace/project-pet-care/frontend/lib/components/organisms/password_warning.dart',
        '/home/arslan/.openclaw/workspace/project-pet-care/frontend/lib/components/organisms/storage_widgets.dart',
    ]
    
    for filepath in files:
        try:
            if fix_file(filepath):
                print(f"Fixed: {filepath}")
            else:
                print(f"No changes needed: {filepath}")
        except Exception as e:
            print(f"Error fixing {filepath}: {e}")
