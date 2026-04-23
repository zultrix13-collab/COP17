import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000/v1';
const ADMIN_TOKEN = __ENV.ADMIN_TOKEN || '';
const SESSION_ID = __ENV.SESSION_ID || '';
const TOKENS_JSON = __ENV.TOKENS_JSON || '[]'; // array of pre-issued QR tokens
const TOKENS = JSON.parse(TOKENS_JSON);

export const options = {
  vus: 100,
  duration: '2m',
  thresholds: {
    http_req_failed:   ['rate<0.01'],
    http_req_duration: ['p(95)<300'],
  },
};

export default function () {
  const token = TOKENS[Math.floor(Math.random() * TOKENS.length)];
  const res = http.post(
    `${BASE_URL}/qr/check-in`,
    JSON.stringify({ token, sessionId: SESSION_ID }),
    { headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${ADMIN_TOKEN}` } },
  );
  check(res, { 'checkin 200/401': (r) => r.status === 200 || r.status === 401 });
}
