/*
 ** TailwindCSS Configuration File
 **
 ** Docs: https://tailwindcss.com/docs/configuration
 ** Default: https://github.com/tailwindcss/tailwindcss/blob/master/stubs/defaultConfig.stub.js
 */

// eslint-disable-next-line
const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  future: {
    purgeLayersByDefault: true,
  },
  purge: {
    content: [
      'components/**/*.vue',
      'layouts/**/*.vue',
      'pages/**/*.vue',
      'plugins/**/*.js',
      'nuxt.config.js',
    ],
    options: {
      whitelist: ['blockquote', 'ul', 'ol', 'li', 'markdown'],
      whitelistPatterns: [
        /^border/,
        /^fade/,
        /^h-/,
        /^mb-/,
        /^md:mb-/,
        /^md:mt-/,
        /^md:my-/,
        /^mt-/,
        /^my-/,
        /^p-/,
        /^sm:h-/,
      ],
    },
  },
  theme: {
    screens: {
      xs: '460px',
      sm: '640px',
      md: '768px',
      lg: '1024px',
      xl: '1280px',
    },
    extend: {
      colors: {
        blue: {
          '050': '#e3f8ff',
          100: '#b3ecff',
          200: '#81defd',
          300: '#5ed0fa',
          400: '#40c3f7',
          500: '#2bb0ed',
          600: '#1992d4',
          700: '#127fbf',
          800: '#0b69a3',
          900: '#035388',
          footer: '#8bccf8',
          dark: '#024775',
        },
      },
      fontFamily: {
        fancy: ['"Mate SC"', 'serif'],
        header: ['Lato', 'sans'],
        serif: ['Noto Serif', ...defaultTheme.fontFamily.serif],
      },
      height: (theme) => ({
        auto: 'auto',
        ...theme('spacing'),
        72: '18rem',
        80: '20rem',
        250: '250px',
        350: '350px',
        400: '400px',
        450: '450px',
        500: '500px',
        600: '600px',
        700: '700px',
        800: '800px',
        900: '900px',
        '1/2-vh': '50vh',
        '3/4-vh': '75vh',
        full: '100%',
        screen: '100vh',
      }),
      minHeight: {
        72: '18rem',
        80: '20rem',
        250: '250px',
        350: '350px',
        400: '400px',
        450: '450px',
        500: '500px',
        600: '600px',
        700: '700px',
        800: '800px',
        900: '900px',
        '1/2-vh': '50vh',
        '3/4-vh': '75vh',
        full: '100%',
        screen: '100vh',
      },
    },
    container: {
      center: true,
      padding: '1rem',
    },
  },
  variants: {
    borderWidth: ['responsive', 'last'],
    fill: ['responsive', 'hover', 'focus'],
    margin: ['responsive', 'last'],
    opacity: ['responsive', 'hover', 'focus', 'group-hover'],
    padding: ['responsive', 'last'],
    textColor: ['responsive', 'hover', 'focus', 'group-hover'],
  },
  plugins: [],
};
