import path from 'path';
import data from './data/articles.json';

const articleCount = Object.values(data).length;
const articleSlugs = Object.keys(data);
const articlePages = [...Array(Math.ceil(articleCount / 3))];

const dynamicRoutes = () => [].concat(
  articlePages.map((_, i) => `/page/${i + 1}`),
  articleSlugs.map((filepath) => `blog/${filepath}`),
);

export default {
  mode: 'universal',
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
    ],
  },
  /*
  ** Customize the progress-bar color
  */
  loading: { color: '#fff' },
  /*
  ** Global CSS
  */
  css: [
  ],
  /*
  ** Plugins to load before mounting the App
  */
  plugins: [
    { src: '~/plugins/cloudinary.js' },
    { src: '~/plugins/vuejs-paginate.js', mode: 'client' },
  ],
  /*
  ** Nuxt.js dev-modules
  */
  buildModules: [
    // Doc: https://github.com/nuxt-community/nuxt-tailwindcss
    '@nuxtjs/tailwindcss',
  ],
  /*
  ** Nuxt.js modules
  */
  modules: [
  ],
  purgeCSS: {
    whitelist: ['blockquote', 'ul', 'ol', 'li'],
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
