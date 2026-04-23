import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000/v1';
const TOKEN    = __ENV.ACCESS_TOKEN || '';
const listLatency = new Trend('programme_list_ms');

export const options = {
  thresholds: {
    http_req_failed:   ['rate<0.005'],
    http_req_duration: ['p(95)<400'],
    programme_list_ms: ['p(95)<250'],
  },
  scenarios: {
    steady: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 100 },
        { duration: '2m',  target: 500 },
        { duration: '1m',  target: 500 },
        { duration: '30s', target: 0 },
      ],
    },
  },
};

const headers = { Authorization: `Bearer ${TOKEN}` };

export default function () {
  // Anonymous read against the Supabase view is the hot path on opening day.
  const res = http.get(`${BASE_URL}/programme/list`, { headers });
  listLatency.add(res.timings.duration);
  check(res, { '200 ok': (r) => r.status === 200 });
  sleep(1 + Math.random() * 2);
}
