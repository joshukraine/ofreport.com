<template>
  <div>
    <h1>Articles tagged with: {{ tag }}</h1>
  </div>
</template>

<script>
import articles from '~/data/articles.json';

const stringParameterize = (tag) => tag.trim()
  .toLowerCase().replace(/[^a-zA-Z0-9 -]/, '').replace(/\s/g, '-');

export default {
  asyncData({ params }) {
    const taggedArticles = Object.values(articles)
      .filter((article) => {
        const safeTags = article.tags.map((tag) => stringParameterize(tag));
        return safeTags.includes(params.tag);
      })
      .map((article) => article);

    return {
      taggedArticles,
      tag: params.tag,
    };
  },
};
</script>
