const parameterize = (tag) => tag.trim()
  .toLowerCase().replace(/[^a-zA-Z0-9 -]/, '').replace(/\s/g, '-');

const getUniqueTags = (articleData) => {
  const rawTags = [];
  Object.values(articleData).map((a) => a.tags
    .map((tag) => rawTags.push(parameterize(tag))));
  return [...new Set(rawTags)];
};

export { parameterize, getUniqueTags };
