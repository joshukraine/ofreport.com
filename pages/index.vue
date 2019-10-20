<template>
  <div>
    <BlogIndex :all-articles="articles" :start-page="1" />
  </div>
</template>

<script>
import BlogIndex from '~/components/BlogIndex.vue';
import data from '~/data/articles.json';

export default {
  components: {
    BlogIndex,
  },
  asyncData() {
    const articles = Object.values(data).reverse();

    return {
      articles,
    };
  },
};
</script>
