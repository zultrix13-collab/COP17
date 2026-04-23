import { ReactNode } from 'react';
import { Navigate } from 'react-router-dom';
import { useSession } from '../features/auth/useSession';

export function RequireAuth({ children }: { children: ReactNode }) {
  const session = useSession();
  if (session === undefined) return null; // loading
  if (session === null) return <Navigate to="/login" replace />;
  return <>{children}</>;
}
