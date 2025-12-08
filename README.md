# RECLAIM.

**Reclaim your time. Reclaim your focus.**

Reclaim is a modern, high-fidelity Flutter application designed to help users break bad habits and track their recovery journey. Built with a sleek, dark aesthetic and smooth animations, it features detailed analytics ("Forensics"), a panic mode for urge surfing, and a gamified leveling system to keep users motivated.

## ⚡ Features

### 🛡️ Dashboard
- **Precision Streak Counter:** Tracks progress down to the second.
- **Gamified Leveling System:** Progress from "Clown" to "God Mode" based on your streak duration.
- **Daily Vibe Check:** Log your mood and thoughts daily to track emotional trends.

### 🚨 Panic Mode
A dedicated toolkit to help you surf the urge when it hits:
- **Breathing Exercises:** Guided 4-7-8 breathing visualization.
- **Flashcards:** Stoic quotes and reminders to shift perspective.
- **Audio Meditation:** Calming soundscapes.
- **Vent Journal:** Write it out, don't act it out.

### 📊 Forensics (Analytics)
Deep dive into your behavioral patterns to prevent future relapses:
- **Danger Zone:** Identifies your most vulnerable days and times (e.g., "Most failures occur on Fridays at 10 PM").
- **Safe Zone:** Highlights your strongest periods and best streaks.
- **Visual Charts:** Hourly heatmaps, weekday breakdowns, and trigger analysis pie charts.

### 📝 Journal & History
- **Relapse Analysis:** Detailed logging of triggers (Stress, Boredom, etc.) and locations.
- **Mood History:** Visual timeline of your daily check-ins.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend:** [Supabase](https://supabase.com/) (Authentication & Database)
- **Animations:** `flutter_animate` for glitch effects and smooth transitions.
- **Charts:** `fl_chart` for data visualization.
- **Typography:** `google_fonts` (Space Grotesk).
- **State Management:** `setState` (Clean Architecture Service-based approach).

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Supabase Account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Malwildan/RECLAIM.git
   cd reclaim
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🎨 Design System
- **Primary Color:** Mint Green (`#B4F8C8`)
- **Danger Color:** Red (`#FF4B4B`)
- **Background:** Pitch Black (`#050505`)
- **Font:** Space Grotesk

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

---
*From us, For us, By us. Developed with empathy.*
