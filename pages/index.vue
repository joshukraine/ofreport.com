<template>
  <div>
    <h1>Home Page</h1>
    <ArticlesList :all-articles="allArticles" :start-page="1" />
  </div>
</template>

<script>
import ArticlesList from '~/components/ArticlesList.vue';
import articles from '~/data/articles.json';

export default {
  components: {
    ArticlesList,
  },
  asyncData() {
    const allArticles = Object.values(articles).reverse();

    return {
      allArticles,
    };
  },
};
</script>
