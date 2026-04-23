import http from 'k6/http';
import { check } from 'k6';

const BASE_URL    = __ENV.BASE_URL || 'http://localhost:3000/v1';
const TOKENS_JSON = __ENV.TOKENS_JSON || '[]'; // per-user access tokens
const PRODUCT_ID  = __ENV.PRODUCT_ID || '';
const TOKENS      = JSON.parse(TOKENS_JSON);

export const options = {
  vus: 50,
  duration: '2m',
  thresholds: {
    http_req_failed: ['rate<0.02'],
    checks:          ['rate>0.98'],
  },
};

export default function () {
  const accessToken = TOKENS[(__VU - 1) % TOKENS.length];
  const h = { 'Content-Type': 'application/json', Authorization: `Bearer ${accessToken}` };

  const bal = http.get(`${BASE_URL}/wallet/balance`, { headers: h });
  check(bal, { 'balance 200': (r) => r.status === 200 });

  const buy = http.post(
    `${BASE_URL}/wallet/purchase`,
    JSON.stringify({ items: [{ productId: PRODUCT_ID, quantity: 1 }] }),
    { headers: h },
  );
  // 400 = insufficient funds is acceptable under load, 500 is not.
  check(buy, { 'buy ok or 400': (r) => r.status === 200 || r.status === 400 });
}
