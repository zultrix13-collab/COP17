/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        tier: {
          green: '#16a34a',
          blue: '#1a6ef5',
          vip: '#7c3aed',
          exhibitor: '#b45309',
          press: '#0369a1',
        },
      },
    },
  },
  plugins: [],
};
