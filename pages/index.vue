<template>
  <div>
    <h1>Home Page</h1>
    <ArticlesList :all-articles="articles" :start-page="1" />
  </div>
</template>

<script>
import ArticlesList from '~/components/ArticlesList.vue';
import data from '~/data/articles.json';

export default {
  components: {
    ArticlesList,
  },
  asyncData() {
    const articles = Object.values(data).reverse();

    return {
      articles,
    };
  },
};
</script>
