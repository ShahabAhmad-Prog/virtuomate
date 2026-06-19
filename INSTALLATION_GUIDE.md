# VIRTUOMATE - Complete Installation Guide

This guide will help you install all the necessary tools and software for developing the VIRTUOMATE mobile app.

---

## System Requirements

- **OS:** Windows 10/11 (64-bit)
- **RAM:** Minimum 8GB (16GB recommended)
- **Storage:** At least 20GB free space
- **Internet:** Required for downloads and API calls

---

## Step-by-Step Installation

### 1. Node.js Installation

**Purpose:** JavaScript runtime needed for React Native and backend development

**Steps:**
1. Visit: https://nodejs.org/
2. Download the **LTS (Long Term Support)** version (v18.x or v20.x)
3. Run the installer (.msi file)
4. Follow installation wizard (use default settings)
5. Verify installation:
   ```powershell
   node --version
   npm --version
   ```
   You should see version numbers.

**Notes:**
- npm (Node Package Manager) is included with Node.js
- Use LTS version for stability

---

### 2. Git Installation

**Purpose:** Version control for your code

**Steps:**
1. Visit: https://git-scm.com/download/win
2. Download the latest version
3. Run the installer
4. During installation:
   - Select "Git from the command line and also from 3rd-party software"
   - Choose "Use the OpenSSL library"
   - Select "Checkout Windows-style, commit Unix-style line endings"
   - Choose "Use Windows' default console window"
5. Complete installation
6. Configure Git:
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```
7. Verify:
   ```powershell
   git --version
   ```

---

### 3. Visual Studio Code Installation

**Purpose:** Code editor for development

**Steps:**
1. Visit: https://code.visualstudio.com/
2. Download Windows version
3. Run installer
4. During installation:
   - Check "Add to PATH"
   - Check "Register Code as an editor for supported file types"
5. Open VS Code

**Essential Extensions to Install:**
1. Open VS Code
2. Click Extensions icon (left sidebar) or press `Ctrl+Shift+X`
3. Install these extensions:
   - **ES7+ React/Redux/React-Native snippets** (by dsznajder)
   - **Prettier - Code formatter** (by Prettier)
   - **ESLint** (by Microsoft)
   - **React Native Tools** (by Microsoft)
   - **GitLens** (by GitKraken)
   - **Auto Rename Tag** (by Jun Han)
   - **Bracket Pair Colorizer 2** (by CoenraadS)
   - **Material Icon Theme** (by Philipp Kief)

---

### 4. Android Studio Installation

**Purpose:** Android development environment (required for React Native Android apps)

**Steps:**
1. Visit: https://developer.android.com/studio
2. Download Android Studio
3. Run installer
4. Follow setup wizard:
   - Standard installation (recommended)
   - Accept licenses
   - Wait for components to download (this may take 15-30 minutes)
5. After installation, open Android Studio
6. Go through first-time setup wizard

**Android SDK Setup:**
1. In Android Studio, click **More Actions** → **SDK Manager**
2. In **SDK Platforms** tab:
   - Check "Android 13.0 (Tiramisu)" or latest
   - Check "Show Package Details"
   - Install all components
3. In **SDK Tools** tab:
   - Check "Android SDK Build-Tools"
   - Check "Android SDK Command-line Tools"
   - Check "Android Emulator"
   - Check "Android SDK Platform-Tools"
   - Check "Intel x86 Emulator Accelerator (HAXM installer)" (if available)
4. Click **Apply** and wait for installation

**Environment Variables Setup:**
1. Press `Win + R`, type `sysdm.cpl`, press Enter
2. Go to **Advanced** tab → **Environment Variables**
3. Under **User variables**, click **New**:
   - Variable name: `ANDROID_HOME`
   - Variable value: `C:\Users\YourUsername\AppData\Local\Android\Sdk`
     (Replace YourUsername with your actual username)
4. Edit **Path** variable:
   - Add: `%ANDROID_HOME%\platform-tools`
   - Add: `%ANDROID_HOME%\tools`
   - Add: `%ANDROID_HOME%\tools\bin`
5. Click **OK** on all dialogs

**Verify Android Setup:**
1. Open new PowerShell window
2. Run:
   ```powershell
   adb version
   ```
   You should see version information.

---

### 5. Java JDK Installation

**Purpose:** Required for Android development

**Steps:**
1. Visit: https://adoptium.net/
2. Download **Temurin 17 (LTS)** for Windows x64
3. Run installer
4. Follow installation wizard (use default settings)
5. Verify:
   ```powershell
   java -version
   ```

**Note:** JDK 17 is recommended for React Native

---

### 6. Expo CLI Installation (For React Native Development)

**Purpose:** Tool to create and manage React Native apps

**Steps:**
1. Open PowerShell (as Administrator recommended)
2. Install Expo CLI globally:
   ```powershell
   npm install -g expo-cli
   ```
3. Install Expo Go app on your phone (optional but recommended):
   - Android: Google Play Store
   - iOS: App Store
4. Verify:
   ```powershell
   expo --version
   ```

**Alternative: Use npx (no installation needed)**
You can also use `npx create-expo-app` without installing Expo CLI globally.

---

### 7. React Native CLI (Alternative - Optional)

**If you want to use React Native CLI instead of Expo:**

```powershell
npm install -g react-native-cli
```

**Note:** For beginners, Expo is recommended as it's easier to set up.

---

### 8. Git GUI (Optional but Recommended)

**GitHub Desktop:**
1. Visit: https://desktop.github.com/
2. Download and install
3. Sign in with GitHub account
4. Easy Git operations without command line

---

### 9. Postman Installation

**Purpose:** API testing tool

**Steps:**
1. Visit: https://www.postman.com/downloads/
2. Download Windows version
3. Install and create account (free)
4. Use for testing backend APIs

---

### 10. MongoDB Installation (If using MongoDB)

**Purpose:** Database for backend (optional - you can use cloud MongoDB Atlas)

**For Local MongoDB:**
1. Visit: https://www.mongodb.com/try/download/community
2. Download Windows version
3. Install with default settings
4. MongoDB Compass (GUI) is included

**OR Use MongoDB Atlas (Cloud - Recommended):**
1. Visit: https://www.mongodb.com/cloud/atlas/register
2. Create free account
3. Create free cluster
4. Get connection string

---

### 11. PostgreSQL Installation (If using PostgreSQL)

**Purpose:** SQL database alternative

**Steps:**
1. Visit: https://www.postgresql.org/download/windows/
2. Download installer
3. Run installer:
   - Remember the password you set for postgres user
   - Port: 5432 (default)
   - Complete installation
4. Install pgAdmin (GUI included)
5. Verify:
   ```powershell
   psql --version
   ```

---

## Development Environment Setup

### Create Your First React Native Project

1. Open PowerShell in your project folder
2. Create Expo project:
   ```powershell
   npx create-expo-app VirtuomateApp
   cd VirtuomateApp
   ```
3. Start development server:
   ```powershell
   npm start
   ```
4. Press `a` for Android emulator or scan QR code with Expo Go app

---

## Essential npm Packages (Install as needed during development)

### Core React Native Packages:
```powershell
npm install @react-navigation/native
npm install @react-navigation/stack
npm install @react-navigation/bottom-tabs
npm install react-native-screens
npm install react-native-safe-area-context
```

### Authentication:
```powershell
npm install firebase
npm install @react-native-async-storage/async-storage
```

### Forms & Validation:
```powershell
npm install formik
npm install yup
```

### Media:
```powershell
npm install react-native-image-picker
npm install react-native-video
npm install react-native-permissions
```

### State Management:
```powershell
npm install @reduxjs/toolkit
npm install react-redux
```

### API Calls:
```powershell
npm install axios
```

### Others (install as needed):
```powershell
npm install react-native-gifted-chat
npm install victory-native
npm install react-native-svg
npm install react-native-reanimated
```

---

## Backend Setup (Node.js Example)

1. Create backend folder:
   ```powershell
   mkdir virtuomate-backend
   cd virtuomate-backend
   ```
2. Initialize project:
   ```powershell
   npm init -y
   ```
3. Install dependencies:
   ```powershell
   npm install express mongoose jsonwebtoken bcrypt cors dotenv
   npm install -D nodemon
   ```
4. Create `server.js` file
5. Start server:
   ```powershell
   npm run dev
   ```

---

## Verification Checklist

After installation, verify everything works:

- [ ] Node.js installed: `node --version`
- [ ] npm installed: `npm --version`
- [ ] Git installed: `git --version`
- [ ] Java installed: `java -version`
- [ ] Android SDK: `adb version`
- [ ] Expo CLI: `expo --version` (if installed)
- [ ] VS Code opens successfully
- [ ] Android Studio opens successfully
- [ ] Can create new Expo project
- [ ] Android emulator runs (create device in Android Studio)

---

## Troubleshooting Common Issues

### Issue: Command not recognized
**Solution:** 
- Restart PowerShell/terminal after installation
- Check PATH environment variables
- Reinstall with "Add to PATH" option checked

### Issue: Android emulator not working
**Solution:**
- Enable virtualization in BIOS
- Install Intel HAXM (in Android Studio SDK Manager)
- Check Windows Hyper-V settings

### Issue: npm install fails
**Solution:**
- Clear npm cache: `npm cache clean --force`
- Delete `node_modules` folder and `package-lock.json`
- Try again: `npm install`

### Issue: Port already in use
**Solution:**
- Kill process using the port:
  ```powershell
  netstat -ano | findstr :8081
  taskkill /PID <PID> /F
  ```

### Issue: Gradle build fails
**Solution:**
- Update Android Studio
- Clean project: `cd android && ./gradlew clean`
- Update Gradle wrapper

---

## Recommended Tools (Optional)

1. **Figma** - Design tool (free)
   - https://www.figma.com/

2. **Notion** - Project documentation (free)
   - https://www.notion.so/

3. **Trello** - Project management (free)
   - https://trello.com/

4. **Discord** - Join React Native community
   - React Native Discord server

---

## Next Steps

After completing installation:

1. ✅ Follow the Week-by-Week Schedule
2. ✅ Start with Week 1, Day 1
3. ✅ Create your first React Native app
4. ✅ Join React Native communities for help

---

## Getting Help

If you encounter issues:

1. Check official documentation
2. Search Stack Overflow
3. Ask in React Native Discord/Reddit
4. Check GitHub issues for specific packages

---

**Good luck with your development journey! 🚀**
