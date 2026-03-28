# Pre-Upload Checklist - Print This

Print this and check off as you go.

---

## BEFORE STARTING
- [ ] Have 2-3 hours free
- [ ] Read UPLOAD_GUIDE.md first
- [ ] Have Google account

---

## FIREBASE SETUP (10 min)
- [ ] Create Firebase project
- [ ] Download credentials JSON
- [ ] Create Firestore database
- [ ] Get Cloud Messaging API key
- [ ] Add credentials to backend

---

## CODE CHANGES (30 min)
- [ ] Replace in-memory storage with Firestore
- [ ] Add notifications feature
- [ ] Update API_BASE_URL to Firebase URL
- [ ] Update version number (1.0.0+1)
- [ ] Test locally: npm start + flutter run

---

## BUILD RELEASE (5 min)
- [ ] Generate signing key (keytool command)
- [ ] Create key.properties file
- [ ] Configure build.gradle
- [ ] Run: flutter build apk --release
- [ ] Save app-release.apk somewhere safe

---

## BACKEND DEPLOYMENT (5 min)
- [ ] Deploy to Firebase Cloud Functions
- [ ] Note backend URL
- [ ] Test backend responds
- [ ] Update frontend API_BASE_URL

---

## DESIGN (20 min)
- [ ] Create app icon (1024x1024 PNG)
- [ ] Take 2-4 screenshots of app
- [ ] Create/write app description
- [ ] Create privacy policy (simple)

---

## GOOGLE PLAY ACCOUNT (5 min)
- [ ] Create account at play.google.com/console
- [ ] Pay $25 registration fee
- [ ] Complete profile

---

## STORE LISTING (30 min)
- [ ] Create new app in Play Console
- [ ] Fill app name
- [ ] Fill short description (80 chars)
- [ ] Fill full description
- [ ] Select category
- [ ] Upload app icon
- [ ] Upload screenshots (2-4)
- [ ] Set content rating
- [ ] Add privacy policy link
- [ ] Add contact email
- [ ] Set minimum OS (Android 7.0+)

---

## TECHNICAL VERIFICATION (10 min)
- [ ] No debug code in release build
- [ ] No hardcoded passwords
- [ ] Permissions are minimal
- [ ] Firebase initialized in app
- [ ] Device tokens being collected
- [ ] Notifications working locally

---

## FINAL UPLOAD (5 min)
- [ ] Upload app-release.apk to Play Console
- [ ] Review everything once more
- [ ] Click "Publish"
- [ ] Wait for Google review (24-48 hours)

---

## AFTER UPLOAD
- [ ] App approved ✅
- [ ] App appears in Play Store
- [ ] Download on real phone to test
- [ ] All features working?

---

**Total Time: 2-3 hours + 1 day review**

**Stuck?**
- Re-read UPLOAD_GUIDE.md
- Check CLOUD.md for details
- Google the error message
- Most issues have simple fixes

**Good luck! 🚀**
