/*
** TailwindCSS Configuration File
**
** Docs: https://tailwindcss.com/docs/configuration
** Default: https://github.com/tailwindcss/tailwindcss/blob/master/stubs/defaultConfig.stub.js
*/
module.exports = {
  theme: {
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
        },
        gray: {
          '050': '#f5f7fa',
          100: '#e4e7eb',
          200: '#cbd2d9',
          300: '#9aa5b1',
          400: '#7b8794',
          500: '#616e7c',
          600: '#52606d',
          700: '#3e4c59',
          800: '#323f4b',
          900: '#1f2933',
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
      },
      borderColor: (theme) => ({
        ...theme('colors'),
        default: theme('colors.gray.100', 'currentColor'),
      }),
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
    },
    container: {
      center: true,
      padding: '1rem',
    },
  },
  variants: {
    opacity: ['responsive', 'hover', 'focus', 'group-hover'],
    textColor: ['responsive', 'hover', 'focus', 'group-hover'],
  },
  plugins: [],
};
