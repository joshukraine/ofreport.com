<template>
  <div>
    <h1>Home Page</h1>
    <ArticlesList :all-articles="allArticles" :start-page="startPage" />
  </div>
</template>

<script>
import ArticlesList from '~/components/ArticlesList.vue';
import articles from '~/data/articles.json';

export default {
  middleware: 'index-redirect',
  components: {
    ArticlesList,
  },
  validate({ params }) {
    return /^\d+$/.test(params.id);
  },
  asyncData({ params }) {
    const allArticles = Object.values(articles).reverse();
    const startPage = parseInt(params.id);

    return {
      allArticles,
      startPage,
    };
  },
};
</script>
