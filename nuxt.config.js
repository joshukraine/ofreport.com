import { build, dynamicRoutes, feed, head } from './config';

export default {
  target: 'static',

  telemetry: true, // https://github.com/nuxt/telemetry

  publicRuntimeConfig: {
    perPage: process.env.PER_PAGE || 8,
  },

  head,

  loading: {
    color: '#2bb0ed',
    height: '3px',
  },

  css: [],

  plugins: [
    '~/plugins/axios.js',
    '~/plugins/cloudinary.client.js',
    '~/plugins/vuejs-paginate.client.js',
    '~/plugins/vuelidate.js',
  ],

  buildModules: ['@nuxtjs/google-analytics', '@nuxtjs/tailwindcss'],

  modules: [
    '@nuxtjs/axios',
    '@nuxtjs/feed',
    '@nuxtjs/toast',
    '@nuxtjs/recaptcha',
    '@nuxtjs/robots',
    '@nuxtjs/sitemap',
  ],

  robots: {
    UserAgent: '*',
    Disallow: process.env.NODE_ENV === 'production' ? '' : '/',
    Sitemap: 'https://ofreport.com/sitemap.xml',
  },

  feed,

  recaptcha: {
    language: 'en',
    siteKey: process.env.OFR_RECAPTCHA_SITE_KEY,
    version: 2,
  },

  toast: {
    position: 'top-center',
    singleton: true,
    iconPack: 'material',
  },

  sitemap: {
    path: '/sitemap.xml',
    hostname: 'https://ofreport.com',
    gzip: true,
  },

  googleAnalytics: {
    id: 'UA-22952661-1',
    dev: false,
  },

  build,

  generate: {
    fallback: true,
    routes: dynamicRoutes(),
  },

  pageTransition: {
    name: 'fade',
    mode: 'out-in',
  },
};
