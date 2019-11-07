import markdownIt from 'markdown-it';
import mila from 'markdown-it-link-attributes';
import path from 'path';
import dynamicRoutes from './lib/dynamic-routes';
import site from './data/site.json';

import { feed } from './config';

/* eslint-disable-next-line import/no-extraneous-dependencies */
require('dotenv').config();

export default {
  mode: 'universal',

  env: {
    perPage: process.env.PER_PAGE || 8,
  },

  head: {
    titleTemplate: (titleChunk) => {
      const baseTitle = 'Joshua and Kelsie Steele — Missionaries serving Christ in Ukraine';
      return titleChunk ? `${titleChunk} | ${baseTitle}` : baseTitle;
    },
    htmlAttrs: {
      lang: site.lang,
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1, viewport-fit=cover' },
      { hid: 'description', name: 'description', content: site.description },
      { hid: 'author', name: 'author', content: site.author },
      { hid: 'robots', name: 'robots', content: process.env.APP_ENV === 'prod' ? 'index,follow' : 'noindex,nofollow' },
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Lato:700&display=swap' },
      { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Mate+SC&display=swap' },
      { rel: 'stylesheet', href: 'https://fonts.googleapis.com/icon?family=Material+Icons&display=swap' },
    ],
  },

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

  purgeCSS: {
    whitelist: [
      'blockquote',
      'ul',
      'ol',
      'li',
      'markdown',
      'mt-6',
      'mb-6',
      'my-6',
      'md:mt-8',
      'md:mb-8',
      'md:my-8',
    ],
    whitelistPatterns: [
      /^fade/,
    ],
  },

  sitemap: {
    path: '/sitemap.xml',
    hostname: 'https://ofreport.com',
    gzip: true,
  },

  build: {
    extractCSS: true,
    /* eslint-disable-next-line no-unused-vars */
    extend(config, ctx) {
      config.module.rules.push(
        {
          test: /\.md$/,
          include: path.resolve(__dirname, 'content'),
          loader: 'frontmatter-markdown-loader',
          options: {
            mode: ['vue-render-functions'],
            markdownIt: markdownIt({
              html: true,
              linkify: true,
              typographer: true,
            }).use(mila, {
              pattern: /^https?:\/\//,
              attrs: {
                target: '_blank',
                rel: 'noopener noreferrer',
              },
            }),
            vue: {
              root: 'markdown',
            },
          },
        },
      );
    },
  },

  generate: {
    fallback: true,
    routes: dynamicRoutes(),
  },

  pageTransition: {
    name: 'fade',
    mode: 'out-in',
  },
};
