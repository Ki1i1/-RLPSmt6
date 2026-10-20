const techColors = {
  primary: '#3b82f6', // Normal
  warning: '#f59e0b', // Peringatan
  danger: '#ef4444', // Kritis
  bg: '#f8fafc', // Surface
}

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        tech: techColors,
        brand: {
          warning: techColors.warning,
        },
      },
      spacing: {
        'safe-area': '1.25rem',
        'safe-pad': '1.25rem',
      },
    },
  },
  plugins: [],
}
