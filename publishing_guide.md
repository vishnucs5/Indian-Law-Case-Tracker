# CaseTrack Publishing Guide

This guide describes how to publish the generated CaseTrack release builds to the **Google Play Store** and the **Apple App Store**.

---

## 1. Publishing to Google Play Store (Android)

You have a signed release Android App Bundle (AAB) file ready at:
`c:\Users\shobhasreenivas\casetrack-full\build\app\outputs\bundle\release\app-release.aab`

### Step-by-Step Upload Instructions:
1. **Log in to Play Console**: Go to the [Google Play Console](https://play.google.com/console/) and sign in with your developer account.
2. **Create App**: Click **Create app**, fill in the App Name ("CaseTrack"), Default Language, App Category, and select whether it is an App or Game and Free or Paid.
3. **Set Up App Listing**: Complete the **Initial Setup Tasks** (Set privacy policy, declare content ratings, target audience, etc.).
4. **Create a Release**:
   - Go to **Production** (under *Release* in the left menu).
   - Click **Create new release** in the top right.
5. **Upload the AAB**: 
   - Drag and drop your `app-release.aab` file into the **App bundles** upload area.
   - Enter a Release Name (e.g., `1.0.0 (1)`) and Release Notes.
6. **Review and Rollout**: Click **Save**, then **Review release**, and finally **Start rollout to Production**.

---

## 2. Publishing to Apple App Store (iOS)

To publish to the App Store, you need a Mac computer with Xcode installed.

### Step-by-Step Xcode Upload Instructions:
1. **Transfer Code**: Copy the project folder (`casetrack-full`) onto your Mac.
2. **Open iOS Project in Xcode**:
   - Open terminal on the Mac, navigate to the project directory, and run `flutter pub get`.
   - Open `ios/Runner.xcworkspace` in Xcode.
3. **Configure Signing & Capabilities**:
   - Click on the root **Runner** project in the left sidebar.
   - Go to the **Signing & Capabilities** tab.
   - Select your Apple Developer Team and ensure your Bundle Identifier (`com.casetrack.app`) is mapped.
4. **Create an Archive**:
   - Select **Any iOS Device (arm64)** as the build destination target.
   - Go to the top menu: **Product** -> **Archive**.
5. **Upload to App Store Connect**:
   - Once the archive completes, the Organizer window will pop up.
   - Click **Distribute App** -> **App Store Connect** -> **Upload**.
6. **Submit for Review**:
   - Log in to [App Store Connect](https://appstoreconnect.apple.com/).
   - Create your app listing, fill in the metadata, select your uploaded build from Xcode, and click **Submit for Review**.
