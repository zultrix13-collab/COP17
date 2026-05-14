import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../../lib/supabase';

const BYPASS = import.meta.env.VITE_BYPASS_AUTH === 'true';

type Step = 'email' | 'otp';

export function LoginPage() {
  const [step, setStep] = useState<Step>('email');
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    if (BYPASS) navigate('/dashboard', { replace: true });
  }, [navigate]);

  const sendOtp = async () => {
    setBusy(true);
    setErr(null);
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { shouldCreateUser: false },
    });
    setBusy(false);
    if (error) return setErr(error.message);
    setStep('otp');
  };

  const verify = async () => {
    setBusy(true);
    setErr(null);
    const { error } = await supabase.auth.verifyOtp({ email, token: code, type: 'email' });
    setBusy(false);
    if (error) return setErr(error.message);
    navigate('/dashboard');
  };

  return (
    <div className="min-h-full flex items-center justify-center bg-gray-50">
      <div className="w-80 bg-white rounded-xl border p-6 space-y-4">
        <div className="text-xl font-bold">COP17 Admin</div>
        {step === 'email' ? (
          <>
            <input
              className="w-full border rounded px-3 py-2 text-sm"
              type="email"
              placeholder="admin@cop17.mn"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <button
              className="w-full bg-black text-white rounded py-2 text-sm disabled:opacity-50"
              disabled={busy || !email}
              onClick={sendOtp}
            >
              {busy ? '…' : 'Код илгээх'}
            </button>
          </>
        ) : (
          <>
            <div className="text-xs text-gray-500">{email} руу код илгээлээ</div>
            <input
              className="w-full border rounded px-3 py-2 text-sm tracking-widest text-center"
              placeholder="________"
              maxLength={8}
              value={code}
              onChange={(e) => setCode(e.target.value)}
            />
            <button
              className="w-full bg-black text-white rounded py-2 text-sm disabled:opacity-50"
              disabled={busy || code.length < 6}
              onClick={verify}
            >
              {busy ? '…' : 'Баталгаажуулах'}
            </button>
          </>
        )}
        {err && <div className="text-xs text-red-600">{err}</div>}
      </div>
    </div>
  );
}
