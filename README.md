# RocketMobileAI — Contacts Search Technical Interview

A production-grade, responsive Flutter application that implements a searchable and paginated contacts list following Clean Architecture principles, Riverpod state management, GetIt service location, Dio networking, and Retrofit client integration.

---

## 1. How to Run the Project

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code (Retrofit & JSON Serializable):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

4. **Run the test suite:**
   ```bash
   flutter test
   ```

5. **Run static analysis:**
   ```bash
   flutter analyze
   ```

---

## 2. Flutter and Dart Versions Used

- **Flutter:** 3.48.0 (channel stable)
- **Dart:** 3.13.2

---

## 3. State Management Solution Chosen & Rationale

We selected **Riverpod (`flutter_riverpod: ^3.4.3`)** with `Notifier` and `NotifierProvider`:

- **Compile-Time Safety & Testability:** Riverpod does not depend on the Flutter widget tree for state logic, enabling clean unit testing with `ProviderContainer` without needing to mock context or build widgets.
- **Race Condition & Cancellation Control:** `Notifier` provides lifecycle callbacks (`ref.onDispose`), allowing proper cancellation of in-flight Dio requests when queries change.
- **Granular Reactivity:** The UI only rebuilds the widgets that depend on specific parts of `ContactsState`, maximizing performance during rapid search typing and infinite scrolling.

---

## 4. Architecture Overview

The codebase is structured around **Clean Architecture**, enforcing strict unidirectional dependency flow:

```
UI (Widgets & Reusable Components)
       ↓
State Notifier / Providers (Riverpod)
       ↓
Domain Layer (Use Cases & Entity Contracts)
       ↓
Data Layer (Repository Impl, DTOs, Remote Data Source)
       ↓
Networking (Retrofit & Dio with Interceptors)
```

### Key Layers:
- **Presentation Layer (`lib/features/contacts/presentation/`)**:
  - `screens/`: `ContactsScreen` hosting scroll listeners and view states.
  - `components/`: Modular stateless widgets (`ContactListItem`, `ContactAvatar`, `ContactSearchBar`, `ContactsEmptyView`, `ContactsErrorView`, `PaginationLoadingIndicator`, `PaginationErrorView`, `ResponsiveLayoutContainer`, `SimulatedErrorSwitch`).
  - `providers/`: `ContactsState` and `ContactsNotifier` handling debounce, pagination, error states, and pull-to-refresh.
- **Domain Layer (`lib/features/contacts/domain/`)**:
  - Pure Dart entities (`ContactEntity`, `ContactsPageEntity`) and abstract contracts (`ContactsRepository`).
  - `GetContactsUseCase` executing business rules independently of frameworks.
- **Data Layer (`lib/features/contacts/data/`)**:
  - `models/`: `ContactModel` and `ContactsResponseModel` with `json_serializable` and `toEntity()` mappings.
  - `datasources/`: `ContactsApiClient` (Retrofit `@RestApi`) and `ContactsRemoteDataSource`.
  - `repositories/`: `ContactsRepositoryImpl` mapping HTTP/Dio exceptions to domain failures (`ServerFailure`, `NetworkFailure`, etc.).
- **Core Layer (`lib/core/`)**:
  - `network/`: `DioFactory`, `MockContactsInterceptor` simulating asynchronous network latency (500–900ms), search filtering, pagination, and simulated errors.
  - `di/`: `injection_container.dart` with `GetIt` for centralized dependency registration.
  - `utils/`: `Debouncer` utility for throttling search inputs (400ms).
  - `theme/`: Professional Material 3 design tokens.

---

## 5. Bonus Features Implemented

- **Request Cancellation & Race Condition Prevention:** When the user types new search queries, previous in-flight requests are immediately cancelled via `Dio.CancelToken` so outdated requests never overwrite new search results.
- **Error Simulation Toggle:** An interactive bug toggle in the AppBar allows instant testing of both the initial request error state and pagination error retry banner.
- **Responsive Layout:** `ResponsiveLayoutContainer` provides adaptive layouts for mobile, tablet, and desktop screens with maximum constraint boundaries.
- **Semantics & Accessibility:** Screen reader labels (`Semantics`) applied to search input, list tiles, and action buttons.
- **Zero Leading Underscores:** Strict code styling adhering to interview constraints (no `_` prefixes before functions or stateless widgets).

---

## 6. What Would Be Improved with Another 2–3 Hours

1. **Persistent Offline Caching (Isar / Hive / Drift):** Store loaded contacts in a local SQLite or Hive database so contacts are available completely offline and immediately rendered during cold start.
2. **Golden / Screenshot UI Tests:** Add golden tests to guarantee visual pixel precision across various screen sizes (iPhone, iPad, Android).
3. **Contact Details & Direct Actions:** Implement a details dialog or bottom sheet allowing direct phone dialing (`url_launcher`) and contact sharing.
4. **Alphabetical Section Jump Index:** Add an alphabet jump sidebar (A–Z) for rapid alphabetical navigation in large datasets.
