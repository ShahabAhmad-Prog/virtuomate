# 🚀 DAY 1 - Your Action Plan: Install Development Tools

**Time Required:** 4-6 hours  
**Goal:** Install all essential development tools to start building VIRTUOMATE

---

## ✅ MORNING SESSION (2-3 hours)

### Step 1: Install Node.js (15-20 minutes)

1. **Open your web browser** and go to: https://nodejs.org/
2. **Download the LTS version** (it will say "LTS" - this is the stable version)
   - Look for the green button that says "LTS" (not "Current")
   - This will download a file like `node-v20.x.x-x64.msi`
3. **Run the installer** (double-click the downloaded file)
4. **Follow the installation wizard:**
   - Click "Next" on all screens
   - Accept the license agreement
   - Use default installation path
   - Make sure "Add to PATH" is checked (it should be by default)
   - Click "Install"
   - Wait for installation to complete
   - Click "Finish"

5. **Verify Installation:**
   - Open PowerShell (Press `Win + X`, then select "Windows PowerShell" or "Terminal")
   - Type these commands one by one:
     ```powershell
     node --version
     npm --version
     ```
   - You should see version numbers (like `v20.11.0` and `10.2.4`)
   - ✅ **If you see version numbers, Node.js is installed correctly!**

**Troubleshooting:** If you get "command not found", restart your computer and try again.

---

### Step 2: Install Git (15-20 minutes)

1. **Go to:** https://git-scm.com/download/win
2. **Download Git for Windows** (it will auto-detect your system)
3. **Run the installer**
4. **During installation, use these settings:**
   - ✅ Select: "Git from the command line and also from 3rd-party software"
   - ✅ Choose: "Use the OpenSSL library"
   - ✅ Select: "Checkout Windows-style, commit Unix-style line endings"
   - ✅ Choose: "Use Windows' default console window"
   - Click "Next" on remaining screens
   - Click "Install"
   - Wait for completion
   - Click "Finish"

5. **Configure Git:**
   - Open PowerShell again
   - Type these commands (replace with YOUR name and email):
     ```powershell
     git config --global user.name "Your Name"
     git config --global user.email "your.email@example.com"
     ```
   - Press Enter after each command

6. **Verify Installation:**
   ```powershell
   git --version
   ```
   - You should see something like `git version 2.43.0`
   - ✅ **If you see a version, Git is installed correctly!**

---

### Step 3: Install Visual Studio Code (10-15 minutes)

1. **Go to:** https://code.visualstudio.com/
2. **Click the big blue "Download for Windows" button**
3. **Run the installer** (the downloaded .exe file)
4. **During installation:**
   - ✅ Check "Add to PATH"
   - ✅ Check "Register Code as an editor for supported file types"
   - ✅ Check "Add to PATH (requires shell restart)"
   - Click "Next" and then "Install"
   - Wait for installation
   - Click "Finish"

5. **Open VS Code** (it should open automatically, or find it in Start Menu)

6. **Install Essential Extensions:**
   - In VS Code, click the **Extensions icon** on the left sidebar (looks like 4 squares) OR press `Ctrl+Shift+X`
   - Search for and install these extensions one by one:
     
     **a) ES7+ React/Redux/React-Native snippets**
     - Search: `ES7+ React/Redux/React-Native snippets`
     - Author: dsznajder
     - Click "Install"
     
     **b) Prettier - Code formatter**
     - Search: `Prettier - Code formatter`
     - Author: Prettier
     - Click "Install"
     
     **c) ESLint**
     - Search: `ESLint`
     - Author: Microsoft
     - Click "Install"
     
     **d) React Native Tools**
     - Search: `React Native Tools`
     - Author: Microsoft
     - Click "Install"
     
     **e) GitLens**
     - Search: `GitLens`
     - Author: GitKraken
     - Click "Install"

7. **Restart VS Code** after installing extensions

✅ **VS Code is ready!**

---

## ☕ BREAK TIME (15-30 minutes)

Take a break! You've completed the morning session. Grab some coffee, stretch, and come back refreshed.

---

## ✅ AFTERNOON SESSION (2-3 hours)

### Step 4: Install Java JDK 17 (15-20 minutes)

1. **Go to:** https://adoptium.net/
2. **Select:**
   - Version: **17 (LTS)**
   - Operating System: **Windows**
   - Architecture: **x64**
3. **Click "Latest release"** to download
4. **Run the installer**
   - Follow the wizard (use default settings)
   - Click "Next" → "Install" → "Finish"

5. **Verify Installation:**
   - Open PowerShell
   ```powershell
   java -version
   ```
   - You should see version info like `openjdk version "17.0.x"`
   - ✅ **If you see version info, Java is installed!**

---

### Step 5: Install Android Studio (30-60 minutes - this is a big one!)

**⚠️ This is the longest installation. Be patient!**

1. **Go to:** https://developer.android.com/studio
2. **Click "Download Android Studio"**
3. **Run the installer** (large file, may take time to download)
4. **During installation:**
   - Click "Next"
   - Select "Standard" installation (recommended)
   - Click "Next" → "Next" → "Install"
   - Wait... this will take 15-30 minutes
   - Click "Next" → "Finish"

5. **First Time Setup:**
   - Android Studio will open
   - If it asks to import settings, choose "Do not import settings"
   - Click "Next" on the welcome screen
   - Choose "Standard" setup
   - Accept licenses (check all boxes, click "Accept" → "Next")
   - Click "Finish"
   - **Wait for Android Studio to download components** (this can take 20-40 minutes)
   - Don't close Android Studio during this process!

6. **Configure Android SDK:**
   - Once Android Studio opens completely, click **"More Actions"** → **"SDK Manager"**
   - In the **SDK Platforms** tab:
     - ✅ Check "Android 13.0 (Tiramisu)" or the latest version
     - ✅ Check "Show Package Details" (optional, but helpful)
   - In the **SDK Tools** tab:
     - ✅ Check "Android SDK Build-Tools"
     - ✅ Check "Android SDK Command-line Tools"
     - ✅ Check "Android Emulator"
     - ✅ Check "Android SDK Platform-Tools"
     - ✅ Check "Intel x86 Emulator Accelerator (HAXM installer)" (if available)
   - Click **"Apply"** → **"OK"**
   - Wait for downloads to complete

7. **Set Up Environment Variables:**
   - Press `Win + R` on your keyboard
   - Type: `sysdm.cpl` and press Enter
   - Click the **"Advanced"** tab
   - Click **"Environment Variables"** button
   - Under **"User variables"**, click **"New"**:
     - Variable name: `ANDROID_HOME`
     - Variable value: `C:\Users\SHAHAB\AppData\Local\Android\Sdk`
       (Replace SHAHAB with your actual Windows username if different)
     - Click **"OK"**
   - Find **"Path"** in User variables, select it, click **"Edit"**
   - Click **"New"** and add these three lines one by one:
     - `%ANDROID_HOME%\platform-tools`
     - `%ANDROID_HOME%\tools`
     - `%ANDROID_HOME%\tools\bin`
   - Click **"OK"** on all dialogs

8. **Verify Android Setup:**
   - **Close and reopen PowerShell** (important for environment variables to take effect)
   - Type:
     ```powershell
     adb version
     ```
   - You should see: `Android Debug Bridge version 1.0.x`
   - ✅ **If you see version info, Android SDK is set up correctly!**

---

### Step 6: Test Your Setup (10 minutes)

Let's make sure everything works together!

1. **Open PowerShell** (new window)

2. **Test Node.js:**
   ```powershell
   node --version
   npm --version
   ```
   ✅ Should show versions

3. **Test Git:**
   ```powershell
   git --version
   ```
   ✅ Should show version

4. **Test Java:**
   ```powershell
   java -version
   ```
   ✅ Should show version

5. **Test Android SDK:**
   ```powershell
   adb version
   ```
   ✅ Should show version

6. **Create a Test File:**
   - Open VS Code
   - Create a new file: `File` → `New File`
   - Save it as `test.js` in any folder
   - Type: `console.log("Hello, VIRTUOMATE!");`
   - Save the file
   - Open PowerShell in that folder
   - Run: `node test.js`
   - You should see: `Hello, VIRTUOMATE!`
   - ✅ **If you see this, everything is working!**

---

## 🎉 CONGRATULATIONS! Day 1 Complete!

You've successfully installed:
- ✅ Node.js and npm
- ✅ Git
- ✅ Visual Studio Code with extensions
- ✅ Java JDK 17
- ✅ Android Studio and Android SDK

---

## 📝 What's Next?

**Tomorrow (Day 2):** You'll start learning JavaScript basics!

**For now:**
- ✅ Mark Day 1 as complete in your checklist
- ✅ Take a well-deserved break!
- ✅ Tomorrow, you'll start coding!

---

## 🆘 Troubleshooting

### If Node.js doesn't work:
- Restart your computer
- Make sure you downloaded the LTS version
- Reinstall if needed

### If Git doesn't work:
- Restart PowerShell
- Make sure you selected "Git from command line" during installation

### If Android Studio is slow:
- This is normal! It's a large application
- Make sure you have at least 8GB RAM
- Close other applications

### If adb command doesn't work:
- Make sure you restarted PowerShell after setting environment variables
- Double-check the ANDROID_HOME path is correct
- Make sure you added the paths to the Path variable

### Need Help?
- Check the INSTALLATION_GUIDE.md for more details
- Search error messages on Google
- Ask in developer communities

---

**Great job completing Day 1! You're on your way to building VIRTUOMATE! 🚀**
