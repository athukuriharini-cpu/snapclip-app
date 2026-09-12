# SnapClip 📋 — Smart Snippet & Clipboard Vault

> Built for the **RevenueCat Shipaton 2026** Hackathon.
> Target Categories: **#BuildInPublic**, **HAMM Award**, **Influencer Award (Productivity)**, **Best App for Galaxy**, **RevenueCat Design Award**.

---

## 💡 Overview

**SnapClip** is a lightning-fast clipboard and reusable snippet vault designed for developers, creators, power users, and busy professionals. It eliminates repetitive typing, lost links, and disorganized notes with one-tap instant copying, tag-based organization, and rich categorization.

---

## ✨ Key Features

- **⚡ Instant 1-Tap Copy & Paste**: One click copies full snippets, templates, and scripts directly to your system clipboard with haptic feedback.
- **📁 Smart Vault & Categories**: Organize your collection by project, tags, or custom emoji folders.
- **🔍 Real-Time Full-Text Search**: Instant search through snippet titles, content bodies, and `#tags`.
- **💻 Syntax & Type Badging**: Automatic formatting for plain text (`📝`), code snippets (`💻`), web links (`🔗`), and graphical assets (`🖼️`).
- **🔗 Direct Link Launcher**: Launch saved URLs in your default browser with a single tap.
- **🌓 Adaptive Material You (M3)**: Beautiful Light and Dark modes customized for high contrast and modern aesthetics.

---

## 💰 Monetization Strategy (HAMM Award & RevenueCat SDK)

SnapClip leverages the official **RevenueCat SDK (`purchases_flutter`)** with a high-converting **Freemium + Subscription** model:

### Free Tier
- Save up to **10 snippets**
- Up to **3 custom categories**
- Full-text search and 1-tap clipboard copying

### SnapClip Pro (\$2.99/mo or \$19.99/yr with 7-day free trial)
- ♾️ **Unlimited Snippets**
- 📂 **Unlimited Custom Folders & Tagging**
- 🖼️ **Rich Image & Screenshot Snippets**
- ☁️ **Cloud Synchronization & Automatic Backups**
- 🔒 **Biometric Vault Lock (Face ID / Fingerprint)**
- ⚡ **Floating Overlay Widget for any app**

### Paywall UX Highlights
- **High-Converting Annual Highlight**: Features a 44% savings discount tag and 7-day trial CTA.
- **Proactive Entitlement Gate**: Soft paywalls trigger on reaching capacity or attempting to add rich media.
- **Full Legal Transparency & Restore**: Built-in 1-tap purchase restoration, Terms of Use, and Privacy links conforming to Store policies.

---

## 📱 Platform Support

- **Samsung Galaxy Store** (Fully supported, 100% free registration)
- **Google Play Store** (Android)
- **Apple App Store** (iOS & iPadOS)

---

## 🛠️ Tech Stack & Architecture

- **Frontend / Mobile Framework**: Flutter 3.x (Dart)
- **State Management**: Riverpod 2.x (StateNotifiers & Providers)
- **Monetization**: RevenueCat Flutter SDK (`purchases_flutter`)
- **Local Persistence**: Hive NoSQL DB (Sub-millisecond read/write latency)
- **Design System**: Material 3 & Google Fonts (Poppins)
