# Theme Development Guide

Complete guide saved to session files.

See: `~/.copilot/session-state/.../files/` for full documentation including:
- Design audit report
- Architecture documentation  
- Testing guide
- Implementation summary

## Quick Reference

**Add a new theme:**
1. Create file in `lib/core/theme/config/themes/your_theme.dart`
2. Extend `ThemeConfig` class
3. Add to `ThemeRegistry._themes` list
4. Done!

**Access theme selector:**
- Navigate to Settings → Theme & Appearance
- Or import: `theme_selector_screen_new.dart`

**Available themes:**
- Warm Orange (default)
- Cool Blue
- Nature Green

Each with light + dark modes!
