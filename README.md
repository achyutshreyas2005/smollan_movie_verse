# Smollan Movie Verse 🎬

A stunning, cinematic, and production-ready movie and TV show discovery application built with Flutter. This app provides a seamless and immersive experience for tracking your favorite shows, discovering what's trending, and managing your upcoming watch schedule.

---

##  Key Features

*   **Cinematic UI/UX:** A highly polished, dark-themed Apple TV+ inspired design with frosted glass effects, subtle drop shadows, and parallax scrolling.
*   **Hero Animations:** Buttery-smooth transitions from the Home Screen to the Details Screen.
*   **Live TVMaze Integration:** Fetches real-time TV shows, upcoming episodes, and cast metadata directly from the public [TVMaze API](https://www.tvmaze.com/api).
*   **Smart "Watch Now" Button:** Automatically opens the show's official streaming site if available, or automatically searches Google for "where to watch [Show Name]" so you never hit a dead end.
*   **Upcoming Schedule Tracker:** View daily or weekly schedules of upcoming episodes, automatically filtering out episodes that have already aired today.
*   **Cross-Platform & Responsive:** Built with `flutter_screenutil` and adaptive grid layouts to look flawless on mobile, tablets, and Flutter Web.
*   **Offline Support & Local Storage:** Powered by **Hive**, allowing you to save favorites to "My List" and retrieve them instantly, even without an internet connection.
*   **Real-time Search:** Lightning-fast, debounced search functionality.
*   **Dark & Light Mode:** Fully adaptive theme switching.

---

## Architecture & Tech Stack

This project strictly adheres to **Clean Architecture** principles, decoupling UI, Business Logic, and Data layers for maximum scalability and testability.

*   **Framework:** Flutter
*   **State Management:** `provider` (ChangeNotifier)
*   **Local Storage (NoSQL):** `hive` & `hive_flutter`
*   **Networking:** `http`
*   **Responsive UI:** `flutter_screenutil`
*   **Animations:** `lottie` & native Implicit Animations
*   **URL Launching & Sharing:** `url_launcher` & `share_plus`
*   **Image Caching:** `cached_network_image`

### Folder Structure

```text
lib/
├── core/
│   ├── enums/        # App-wide UI states (loading, success, error)
│   ├── theme/        # Apple TV+ inspired cinematic theme definitions
│   └── utils/        # URL Launchers, Debouncers
├── data/
│   ├── local/        # Hive Database Services & TypeAdapters
│   ├── models/       # ShowModel, EpisodeModel, ScheduleModel
│   └── services/     # TVMaze API Service calls
├── providers/        # State Management (ShowsProvider, UpcomingProvider, etc.)
├── screens/          # Application Pages (Home, Details, Search, Upcoming, Favorites)
├── widgets/          # Reusable UI Components (CinematicBanner, ShowCard, Glassmorphism)
└── main.dart         # Entry point and MultiProvider setup
```

---

## Getting Started

### Prerequisites
*   Flutter SDK (v3.19.0 or higher recommended)
*   Dart SDK

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/smollan_movie_verse.git
    cd smollan_movie_verse
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```
    *Note: To run on the web, use `flutter run -d chrome`.*

---

## Screenshots & UI Highlights

*   **Home Screen:** Features a massive top `CinematicBanner` that parallax scrolls behind a frosted-glass `SliverAppBar`. Show cards perfectly maintain a premium `2:3` aspect ratio with ambient shadows.
*   **Details Screen:** Features a massive hero poster that gracefully collapses, expanding metadata, genres, and cast details.
*   **Upcoming Screen:** Shows an episodic breakdown of what airs Today, Tomorrow, and This Week.

---

## Future Enhancements

*   **Authentication:** Firebase integration for cross-device syncing of the "My List".
*   **Pagination:** Advanced infinite scrolling for the search page.
*   **Deep Linking:** Allows sharing of specific movie screens natively to other users.
*   **Trailer Support:** Embedded YouTube player for TV show trailers.

---
## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
