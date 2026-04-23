import { createBrowserRouter, Navigate } from 'react-router-dom';
import { AppShell } from './components/AppShell';
import { RequireAuth } from './components/RequireAuth';
import { LoginPage } from './features/auth/LoginPage';
import { DashboardPage } from './features/dashboard/DashboardPage';
import { UsersPage } from './features/users/UsersPage';
import { BulkTierPage } from './features/users/BulkTierPage';
import { ProgrammePage } from './features/programme/ProgrammePage';
import { ReportsPage } from './features/reports/ReportsPage';
import { PaymentsPage } from './features/payments/PaymentsPage';
import { MeetingsPage } from './features/meetings/MeetingsPage';
import { AlertsPage } from './features/alerts/AlertsPage';

export const router = createBrowserRouter([
  { path: '/login', element: <LoginPage /> },
  {
    path: '/',
    element: (
      <RequireAuth>
        <AppShell />
      </RequireAuth>
    ),
    children: [
      { index: true, element: <Navigate to="/dashboard" replace /> },
      { path: 'dashboard', element: <DashboardPage /> },
      { path: 'users', element: <UsersPage /> },
      { path: 'users/bulk', element: <BulkTierPage /> },
      { path: 'programme', element: <ProgrammePage /> },
      { path: 'meetings', element: <MeetingsPage /> },
      { path: 'payments', element: <PaymentsPage /> },
      { path: 'alerts', element: <AlertsPage /> },
      { path: 'reports', element: <ReportsPage /> },
    ],
  },
]);
