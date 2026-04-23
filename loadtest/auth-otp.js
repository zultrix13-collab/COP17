import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000/v1';

export const options = {
  vus: 200,
  duration: '1m',
  thresholds: {
    // OTP endpoint is rate-limited; we EXPECT 429s above the limit.
    // Check that we never 500.
    'http_req_failed{status:500}': ['count==0'],
  },
};

export default function () {
  const email = `load-${__VU}-${__ITER}@example.mn`;
  const res = http.post(
    `${BASE_URL}/auth/otp/request`,
    JSON.stringify({ email }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  check(res, { 'no 500': (r) => r.status < 500 });
}
