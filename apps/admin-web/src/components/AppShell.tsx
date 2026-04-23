import { NavLink, Outlet } from 'react-router-dom';
import { useTranslation } from 'react-i18next';

export function AppShell() {
  const { t, i18n } = useTranslation();
  const linkCls = ({ isActive }: { isActive: boolean }) =>
    `block px-3 py-2 rounded text-sm ${isActive ? 'bg-black text-white' : 'text-gray-700 hover:bg-gray-100'}`;

  return (
    <div className="flex h-full">
      <aside className="w-56 border-r bg-white p-4">
        <div className="font-bold mb-6">{t('app.title')}</div>
        <nav className="space-y-1">
          <NavLink to="/dashboard" className={linkCls}>{t('nav.dashboard')}</NavLink>
          <NavLink to="/users" className={linkCls}>{t('nav.users')}</NavLink>
          <NavLink to="/users/bulk" className={linkCls}>{t('nav.bulk')}</NavLink>
          <NavLink to="/programme" className={linkCls}>{t('nav.programme')}</NavLink>
          <NavLink to="/meetings" className={linkCls}>{t('nav.meetings')}</NavLink>
          <NavLink to="/payments" className={linkCls}>{t('nav.payments')}</NavLink>
          <NavLink to="/alerts" className={linkCls}>{t('nav.alerts')}</NavLink>
          <NavLink to="/reports" className={linkCls}>{t('nav.reports')}</NavLink>
        </nav>
        <div className="mt-auto pt-8">
          <button
            className="text-xs text-gray-500 hover:text-black"
            onClick={() => i18n.changeLanguage(i18n.language === 'mn' ? 'en' : 'mn')}
          >
            {i18n.language === 'mn' ? 'EN' : 'МН'}
          </button>
        </div>
      </aside>
      <main className="flex-1 overflow-auto p-6 bg-gray-50">
        <Outlet />
      </main>
    </div>
  );
}
