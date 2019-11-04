import markdownIt from 'markdown-it';
import mila from 'markdown-it-link-attributes';
import path from 'path';
import dynamicRoutes from './lib/dynamic-routes';

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
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1, viewport-fit=cover' },
      { hid: 'description', name: 'description', content: 'Joshua and Kelsie are missionaries enjoying life as best friends, serving their Savior, and raising up their children to honor Him.' },
      { name: 'author', content: 'Joshua and Kelsie Steele' },
      { hid: 'robots', name: 'robots', content: process.env.APP_ENV === 'production' ? 'index,follow' : 'noindex,nofollow' },
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
    '@nuxtjs/toast',
  ],

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
};
