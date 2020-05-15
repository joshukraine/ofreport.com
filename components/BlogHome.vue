<template>
  <div>
    <ArticlesList
      :all-articles="allArticles"
      :start-page="startPage"
      :root-segment="rootSegment"
    />
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
      rootSegment: 'blog',
    };
  },
  created() {
    this.allArticles = Object.values(articles).reverse();
  },
};
</script>
