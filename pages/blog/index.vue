<template>
  <section>
    <BlogHome :start-page="1" />
  </section>
</template>

<script>
import BlogHome from '~/components/BlogHome.vue';

export default {
  components: {
    BlogHome,
  },
  head() {
    return {
      title: 'Blog',
    };
  },
};
</script>
