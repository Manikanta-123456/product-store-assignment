# StyleStore - Product Discovery App

## 🚀 Features
- **Product Feed:** Real-time data fetching from FakeStoreAPI.
- **Persistence:** Likes/Dislikes are saved locally using Shared Preferences.
- **Internal WebView:** View product details without leaving the app.
- **State Management:** Centralized state using the Provider package.

## 🛠️ Architecture
The project follows a modular structure to separate business logic from the UI:
- **Models:** Data parsing for API responses.
- **Services:** API and Local Storage handling.
- **Providers:** State logic for likes and feed management.
- **Screens:** UI components and WebView integration.
