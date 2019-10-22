import path from 'path';
import articles from './data/articles.json';

/* eslint-disable-next-line import/no-extraneous-dependencies */
require('dotenv').config();

const perPage = parseInt(process.env.PER_PAGE);

const parameterize = (tag) => tag.trim()
  .toLowerCase().replace(/[^a-zA-Z0-9 -]/, '').replace(/\s/g, '-');

// Calculate article values
const articleCount = Object.values(articles).length;
const articleSlugs = Object.keys(articles);
const articlePages = [...Array(Math.ceil(articleCount / perPage))];

// Calculate tag values
const rawTags = [];
Object.values(articles).map((a) => a.tags
  .map((tag) => rawTags.push(parameterize(tag))));
const uniqueTags = [...new Set(rawTags)];

// Function for retrieving articles which match a give tag
const taggedArticlesFor = (tag) => Object.values(articles)
  .filter((article) => {
    const safeTags = article.tags.map((t) => parameterize(t));
    return safeTags.includes(tag);
  })
  .map((article) => article);

// deepTagArray returns a nested array of path groups.
// Example:
// [
//   [ '/tags/cmo/page/1', '/tags/cmo/page/2', '/tags/cmo/page/3' ],
//   [ '/tags/video/page/1', '/tags/video/page/2', '/tags/video/page/3' ],
//   [ '/tags/family/page/1', '/tags/family/page/2', '/tags/family/page/3' ],
// ]
const deepTagArray = uniqueTags.map((tag) => {
  const localArticles = taggedArticlesFor(tag);
  const localArticleCount = localArticles.length;
  const tagPages = [...Array(Math.ceil(localArticleCount / perPage))];

  const tagPathGroup = [];
  tagPages.map((_, i) => tagPathGroup.push(`/tags/${tag}/page/${i + 1}`));

  // tagPathGroup is an array of paths.
  // Example: [ '/tags/cmo/page/1', '/tags/cmo/page/2', '/tags/cmo/page/3' ]
  return tagPathGroup;
});

const dynamicRoutes = () => [].concat(
  articleSlugs.map((slug) => `/blog/${slug}`),
  articlePages.map((_, i) => `/page/${i + 1}`),
  uniqueTags.map((tag) => `/tags/${tag}`),
  [].concat(...deepTagArray),
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
    '@nuxtjs/dotenv',
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
