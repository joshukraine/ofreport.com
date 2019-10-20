<template>
  <div>
    <BlogIndex :articles="articles" />
  </div>
</template>

<script>
import BlogIndex from '~/components/BlogIndex.vue';
import data from '~/data/articles.json';

const perPage = 3;

export default {
  components: {
    BlogIndex,
  },
  asyncData() {
    const articles = Object.values(data).reverse().slice(0, perPage);

    return {
      articles,
    };
  },
};
</script>
