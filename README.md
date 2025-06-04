# GitHub User Viewer

---

## 👤 Author

Developed by **Phan Hoàng Long**  
For showcasing iOS development skills as part of the application process for the **iOS Developer** position at **Tymex**.

## 🚀 Getting Started

The project uses Swift Package Manager (SPM) to manage third-party libraries.  
To run the project:

1. Clone the repository
2. Open the `.xcodeproj` or `.xcworkspace` file in Xcode
3. **Resolve Swift Packages**
4. Build and run the app

That's it — no additional configuration is required.

---

## 🧱 Project Architecture

- **MVVM (Model - View - ViewModel)

---

## 📦 Integrated Libraries (via Swift Package Manager)

| Library         | Purpose                                                                 |
|----------------|-------------------------------------------------------------------------|
| **RxSwift**     | Enables reactive programming and data binding in the MVVM layer         |
| **RxCocoa**     | Provides reactive extensions for UIKit                                  |
| **Kingfisher**  | Efficiently loads and caches images from URLs                           |
| **RxTest**      | Provides tools for simulating time-based sequences in unit tests        |
| **RxBlocking**  | Allows blocking on observables for simplified test assertions           |

---

## 🔗 Data Layer

- Uses **native `URLSession`** for API calls to GitHub's public API.
- **UserDefaults** is used to cache the user list locally to reduce API calls and improve UX.

---

## 🧪 Unit Testing

The project includes unit tests for ViewModels, Services:

- **Reactive Testing**: `RxTest` and `RxBlocking` are used to test reactive streams and state transitions.
- **Non-Reactive Testing**: In addition to Rx, we demonstrate traditional testing by exposing clean synchronous outputs from ViewModels to assert logic independently of Rx abstractions.
---
