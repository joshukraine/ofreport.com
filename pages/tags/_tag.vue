<template>
  <div>
    <h1>Articles tagged with: {{ tag }}</h1>

    <div v-for="article in taggedArticles"
         :key="article.basename"
         class="markdown"
    >
      <h2>{{ article.title }}</h2>
      <p>{{ article.preview }}</p>
      <nuxt-link :to="`/blog/${article.basename}`">
        Read
      </nuxt-link>
    </div>
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
