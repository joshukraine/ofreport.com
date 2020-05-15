import articles from '../data/articles.json';
import { getUniqueTags, getArticlesTaggedWith } from './utils/helpers';

/* eslint-disable-next-line import/no-extraneous-dependencies */
require('dotenv').config();

const perPage = parseInt(process.env.PER_PAGE);
const articleCount = Object.values(articles).length;
const articleSlugs = Object.keys(articles);
const articlePages = [...Array(Math.ceil(articleCount / perPage))];
const uniqueTags = getUniqueTags(articles);

// deepTagArray returns a nested array of path groups.
// Example:
// [
//   [ '/tags/cmo/page/1', '/tags/cmo/page/2', '/tags/cmo/page/3' ],
//   [ '/tags/video/page/1', '/tags/video/page/2', '/tags/video/page/3' ],
//   [ '/tags/family/page/1', '/tags/family/page/2', '/tags/family/page/3' ],
// ]
const deepTagArray = uniqueTags.map((tag) => {
  const localArticles = getArticlesTaggedWith(tag[0]);
  const localArticleCount = localArticles.length;
  const tagPages = [...Array(Math.ceil(localArticleCount / perPage))];

  const tagPathGroup = [];
  tagPages.map((_, i) => tagPathGroup.push(`/tags/${tag[0]}/page/${i + 1}`));

  // tagPathGroup is an array of paths.
  // Example: [ '/tags/cmo/page/1', '/tags/cmo/page/2', '/tags/cmo/page/3' ]
  return tagPathGroup;
});

export default () =>
  [].concat(
    articleSlugs.map((slug) => `/blog/${slug}`),
    articlePages.map((_, i) => `/blog/page/${i + 1}`),
    uniqueTags.map((tag) => `/tags/${tag[0]}`),
    [].concat(...deepTagArray)
  );
