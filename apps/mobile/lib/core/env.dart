const demoMode = bool.fromEnvironment('DEMO_MODE');

/// App-review access for store reviewers (Google Play / App Store).
///
/// The app signs in via Supabase email OTP, but the reviewer account
/// `delegate@siop.mn` lives on a domain with no mailbox, so a real code can
/// never be delivered. Entering this exact email + code unlocks a local,
/// demo-data-only session — no Supabase session and no access to real delegate
/// data. It is treated like [demoMode] for routing and data sources.
const reviewEmail = 'delegate@siop.mn';
const reviewCode = '250628';

/// Set to true once a reviewer signs in with [reviewEmail] + [reviewCode].
bool reviewSession = false;
