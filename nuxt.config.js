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
  /*
  ** Headers of the page
  */
  head: {
    title: process.env.npm_package_name || '',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: process.env.npm_package_description || '' },
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Lato:700&display=swap' },
      { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Mate+SC&display=swap' },
    ],
  },
  /*
  ** Customize the progress-bar color
  */
  loading: { color: '#2bb0ed' },
  /*
  ** Global CSS
  */
  css: [
    '@fortawesome/fontawesome-svg-core/styles.css',
  ],
  /*
  ** Plugins to load before mounting the App
  */
  plugins: [
    '~/plugins/axios.js',
    '~/plugins/cloudinary.client.js',
    '~/plugins/fontawesome.js',
    '~/plugins/vuejs-paginate.client.js',
    '~/plugins/vuelidate.js',
  ],
  /*
  ** Nuxt.js dev-modules
  */
  buildModules: [
    '@nuxtjs/dotenv',
    '@nuxtjs/moment',
    '@nuxtjs/tailwindcss',
  ],
  /*
  ** Nuxt.js modules
  */
  modules: [
    '@nuxtjs/axios',
  ],
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
      /^svg-inline/,
      /^fa$/,
      /^fa-/,
      /^fab/,
      /^fas/,
      /^fal/,
      /^far/,
      /--fa$/,
      /^sr-/,
    ],
  },
  /*
  ** Build configuration
  */
  build: {
    /*
    ** You can extend webpack config here
    */
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
    routes: dynamicRoutes(),
  },
};
