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
  components: {
    ArticlesList,
  },
  props: {
    startPage: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      allArticles: [],
    };
  },
  created() {
    this.allArticles = Object.values(articles).reverse();
  },
};
</script>
