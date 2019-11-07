import {
  build, dynamicRoutes, feed, head, purgeCSS,
} from './config';

/* eslint-disable-next-line import/no-extraneous-dependencies */
require('dotenv').config();

export default {
  mode: 'universal',

  env: {
    perPage: process.env.PER_PAGE || 8,
  },

  head,

  loading: {
    color: '#2bb0ed',
    height: '3px',
  },

  css: [
  ],

  plugins: [
    '~/plugins/axios.js',
    '~/plugins/cloudinary.client.js',
    '~/plugins/vuejs-paginate.client.js',
    '~/plugins/vuelidate.js',
  ],

  buildModules: [
    '@nuxtjs/dotenv',
    '@nuxtjs/tailwindcss',
  ],

  modules: [
    '@nuxtjs/axios',
    '@nuxtjs/feed',
    '@nuxtjs/toast',
    '@nuxtjs/recaptcha',
    '@nuxtjs/sitemap',
  ],

  feed,

  recaptcha: {
    language: 'en',
    siteKey: process.env.OFR_RECAPTCHA_SITE_KEY,
    version: 2,
  },

  toast: {
    position: 'bottom-right',
    singleton: true,
    iconPack: 'material',
  },

  purgeCSS,

  sitemap: {
    path: '/sitemap.xml',
    hostname: 'https://ofreport.com',
    gzip: true,
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
