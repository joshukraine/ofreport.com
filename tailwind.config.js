/*
** TailwindCSS Configuration File
**
** Docs: https://tailwindcss.com/docs/configuration
** Default: https://github.com/tailwindcss/tailwindcss/blob/master/stubs/defaultConfig.stub.js
*/
module.exports = {
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
        header: [
          'Lato',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Roboto',
          '"Helvetica Neue"',
          'Arial',
          '"Noto Sans"',
          'sans-serif',
          '"Apple Color Emoji"',
          '"Segoe UI Emoji"',
          '"Segoe UI Symbol"',
          '"Noto Color Emoji"',
        ],
        fancy: [
          '"Mate SC"',
          'serif',
        ],
      },
      height: (theme) => ({
        auto: 'auto',
        ...theme('spacing'),
        72: '18rem',
        80: '20rem',
        '400px': '400px',
        '500px': '500px',
        '600px': '600px',
        '700px': '700px',
        '800px': '800px',
        '900px': '900px',
        full: '100%',
        screen: '100vh',
      }),
      minHeight: {
        250: '250px',
        350: '350px',
        450: '450px',
        500: '500px',
        600: '600px',
        700: '700px',
        '1/2-vh': '50vh',
        '3/4-vh': '75vh',
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
