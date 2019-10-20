<template>
  <div>
    <BlogIndex :all-articles="articles" :start-page="startPage" />
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
    const startPage = parseInt(params.id);

    return {
      articles,
      startPage,
    };
  },
};
</script>
