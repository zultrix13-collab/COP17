const demoMode = bool.fromEnvironment('DEMO_MODE');

/// App-review credentials injected at build time via --dart-define.
/// Both are empty strings in production builds (no --dart-define supplied),
/// which means the bypass is completely disabled unless explicitly enabled.
const reviewEmail = String.fromEnvironment('REVIEW_EMAIL');
const reviewCode = String.fromEnvironment('REVIEW_CODE');

/// Set to true once a reviewer signs in with [reviewEmail] + [reviewCode].
bool reviewSession = false;

/// Congress dates — single source of truth for countdowns, date guards, etc.
final kCongressStart = DateTime(2026, 6, 25);
final kCongressEnd = DateTime(2026, 6, 28);
