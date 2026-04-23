# COP17 load tests (k6)

Install k6: `brew install k6` (macOS) or see https://k6.io.

## Scenarios

| Script | Traffic shape | What it proves |
|--------|---------------|----------------|
| `programme.js`        | 500 vus read bursts | Programme list + detail survive opening-ceremony viewing spike |
| `auth-otp.js`         | 200 vus, OTP request spam | OTP rate-limit + Supabase `signInWithOtp` backpressure |
| `qr-checkin.js`       | 100 vus, sustained scan | QR HMAC verify + attendance upsert handles Hall-entry burst |
| `wallet-purchase.js`  | 50 vus mixed reads/writes | Wallet RPC atomicity (no double-debit, no phantom credits) |

Run:

```bash
k6 run -e BASE_URL=https://stg-api.cop17.mn loadtest/programme.js
```

Success gate (SLO): p95 < 400 ms, error rate < 0.5 %.
