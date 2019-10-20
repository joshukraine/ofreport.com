<template>
  <div>
    <BlogIndex :all-articles="articles" :current-page="currentPage" />
  </div>
</template>

<script>
import BlogIndex from '~/components/BlogIndex.vue';
import data from '~/data/articles.json';

export default {
  components: {
    BlogIndex,
  },
  asyncData({ params }) {
    const articles = Object.values(data).reverse();
    const currentPage = parseInt(params.id);

    return {
      articles,
      currentPage,
    };
  },
};
</script>
