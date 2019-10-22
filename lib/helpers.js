import articles from '../data/articles.json';

const parameterize = (tag) => tag.trim()
  .toLowerCase().replace(/[^a-zA-Z0-9 -]/, '').replace(/\s/g, '-');

const getUniqueTags = (articleData) => {
  const rawTags = [];
  Object.values(articleData).map((a) => a.tags
    .map((tag) => rawTags.push(parameterize(tag))));
  return [...new Set(rawTags)];
};

const getArticlesTaggedWith = (tag) => Object.values(articles)
  .filter((article) => {
    const safeTags = article.tags.map((t) => parameterize(t));
    return safeTags.includes(tag);
  }).map((article) => article);

export { parameterize, getUniqueTags, getArticlesTaggedWith };
