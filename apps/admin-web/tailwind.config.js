/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          primary: '#14464F',
          sky:     '#05B6C4',
          sand:    '#F5D9A8',
        },
        tier: {
          green:     '#059669',
          blue:      '#05B6C4',
          vip:       '#8B5CF6',
          exhibitor: '#D97706',
          press:     '#0369A1',
        },
      },
      fontFamily: {
        sans: ['Manrope', 'ui-sans-serif', 'system-ui'],
      },
    },
  },
  plugins: [],
};
