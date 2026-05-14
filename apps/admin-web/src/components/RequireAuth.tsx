import { ReactNode } from 'react';
import { Navigate } from 'react-router-dom';
import { useSession } from '../features/auth/useSession';

const BYPASS = import.meta.env.VITE_BYPASS_AUTH === 'true';

export function RequireAuth({ children }: { children: ReactNode }) {
  const session = useSession();
  if (BYPASS) return <>{children}</>;
  if (session === undefined) return null; // loading
  if (session === null) return <Navigate to="/login" replace />;
  return <>{children}</>;
}
