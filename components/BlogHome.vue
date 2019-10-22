<template>
  <div>
    <Alpha />
    <ArticlesList :all-articles="allArticles" :start-page="startPage" />
  </div>
</template>

<script>
import Alpha from '~/components/Alpha.vue';
import ArticlesList from '~/components/ArticlesList.vue';
import articles from '~/data/articles.json';

export default {
  components: {
    Alpha,
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
