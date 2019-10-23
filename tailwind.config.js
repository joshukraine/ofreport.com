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
          '050': '#E3F8FF',
          100: '#B3ECFF',
          200: '#81DEFD',
          300: '#5ED0FA',
          400: '#40C3F7',
          500: '#2BB0ED',
          600: '#1992D4',
          700: '#127FBF',
          800: '#0B69A3',
          900: '#035388',
        },
        gray: {
          '050': '#F5F7FA',
          100: '#E4E7EB',
          200: '#CBD2D9',
          300: '#9AA5B1',
          400: '#7B8794',
          500: '#616E7C',
          600: '#52606D',
          700: '#3E4C59',
          800: '#323F4B',
          900: '#1F2933',
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
        default: theme('colors.gray.200', 'currentColor'),
      }),
      height: (theme) => ({
        auto: 'auto',
        ...theme('spacing'),
        72: '18rem',
        80: '20rem',
        '400px': '400px',
        '500px': '500px',
        '600px': '600px',
        full: '100%',
        screen: '100vh',
      }),
    },
    container: {
      center: true,
    },
  },
  variants: {
    opacity: ['responsive', 'hover', 'focus', 'group-hover'],
    textColor: ['responsive', 'hover', 'focus', 'group-hover'],
  },
  plugins: [],
};
