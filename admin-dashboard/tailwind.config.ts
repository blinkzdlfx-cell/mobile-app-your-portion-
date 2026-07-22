import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#012d1d', 50: '#e6f0ec', 100: '#b3d1c4', 200: '#80b39b', 300: '#4d9473', 400: '#1a754a', 500: '#012d1d', 600: '#012418', 700: '#011b13', 800: '#01120e', 900: '#000909' },
        sage: { DEFAULT: '#1b4332', 50: '#e8f0ec', 100: '#b8d1c4', 200: '#8ab39b', 300: '#5c9473', 400: '#3a7a5a', 500: '#1b4332', 600: '#163628', 700: '#10291e', 800: '#0b1c14', 900: '#050e0a' },
        cream: '#fcf9f8',
      },
      keyframes: {
        'slide-up': {
          '0%': { transform: 'translateY(1rem)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        'fade-in': {
          '0%': { opacity: '0', transform: 'translateY(0.25rem)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        'slide-in-right': {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(0)' },
        },
      },
      animation: {
        'slide-up': 'slide-up 0.3s ease-out',
        'fade-in': 'fade-in 0.3s ease-out',
        'slide-in-right': 'slide-in-right 0.25s ease-out',
      },
    },
  },
  plugins: [],
}
export default config
