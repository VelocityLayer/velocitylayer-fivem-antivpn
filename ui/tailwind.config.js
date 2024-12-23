/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'dashboard-dark': '#0f172a',
        'dashboard-darker': '#070d1b',
        'button-hover': '#172340',
        'button-selected': '#263b6b',
        'accent': '#3b82f6'
      },
    },
  },
  plugins: [
    require('tailwindcss-motion')
  ],
}

