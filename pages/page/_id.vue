<template>
  <div>
    <h1>Home Page</h1>
    <ArticlesList :all-articles="articles" :start-page="startPage" />
  </div>
</template>

<script>
import ArticlesList from '~/components/ArticlesList.vue';
import data from '~/data/articles.json';

export default {
  middleware: 'index-redirect',
  components: {
    ArticlesList,
  },
  validate({ params }) {
    return /^\d+$/.test(params.id);
  },
  asyncData({ params }) {
    const articles = Object.values(data).reverse();
    const startPage = parseInt(params.id);

    return {
      articles,
      startPage,
    };
  },
};
</script>
