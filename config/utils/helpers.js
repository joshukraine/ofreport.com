import countBy from 'lodash.countby';
import articles from '../../data/articles.json';

const parameterize = (tag) =>
  tag
    .trim()
    .toLowerCase()
    .replace(/[^a-zA-Z0-9 -]/, '')
    .replace(/\s/g, '-');

const getUniqueTags = (articleData) => {
  const rawTags = [];
  Object.values(articleData).map((a) =>
    a.tags.map((tag) => rawTags.push(parameterize(tag)))
  );
  return Object.entries(countBy(rawTags));
};

const getArticlesTaggedWith = (tag) =>
  Object.values(articles)
    .filter((article) => {
      const safeTags = article.tags.map((t) => parameterize(t));
      return safeTags.includes(tag);
    })
    .map((article) => article);

const cldOptimize = (url, opts) => {
  if (!url) {
    return false;
  }
  const optionStr = `upload/${opts.join(',')}`;
  const segments = url.split('upload');
  segments.splice(1, 0, optionStr);
  return segments.join('');
};

export { parameterize, getUniqueTags, getArticlesTaggedWith, cldOptimize };
