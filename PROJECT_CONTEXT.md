# Project Context

This file serves as the foundation for understanding and iterating on the **Project Pet** application. Below is the consolidated project context distilled from existing files and configurations.

## Objective
The **Project Pet** is designed to assist pet owners in managing pet care through a Flutter-based app synced with a Firebase backend. The application aims to provide:

- **Pet Profiles**: To store and visualize pet details.
- **Task/Reminder Management**: Notifications for key dates and daily needs.
- **Dynamic User Interface**: Including themes based on pet specifics.

---

## Structure Overview
### Backend (Firebase):
- **Configuration**:
  - `firebase-config.js`: Contains Firebase API keys and app-specific settings.
  - Services initialized for database, authentication, and storage.

- **Validation**:
  - `validate-firebase.js` checks service connectivity.

### Frontend (Flutter):
- **Entry Point**:
  - `main.dart`: Initializes Material-based UI and routing.
- **Components**:
  - Navbar and themes dynamically invoked to support profiles.

---

## Workflow Notes:
### File Safety:
- Enabled the use of `trash-cli` and aliases (`rm = trash`). This ensures safe file operations by preventing permanent deletion via `rm`. Aliases available:
  - `tl` → List contents.
  - `tr` → Restore files.
  - `te` → Empty the trash.

### Git Commit Policy (Generated Files)

- Do not commit generated, machine-local, or cache artifacts.
- Files covered by `.gitignore` must stay untracked (build output, caches, logs, temporary files, local IDE state, emulator runtime files).
- Commit only source files, configuration templates, and documentation needed to reproduce builds.
- Keep lockfiles that are part of dependency reproducibility (`pubspec.lock` is tracked for app builds in this project unless team policy changes explicitly).
- If a new tool generates noisy files, add patterns to the root `.gitignore` before committing.
- Before pushing, run `git status --ignored --short` and confirm no accidental generated artifacts are staged.

---
Changes or further insights should document their rationale directly within this file. This ensures all adjustments are traceable.