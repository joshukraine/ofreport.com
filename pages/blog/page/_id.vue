<template>
  <section>
    <BlogHome :start-page="startPage" />
  </section>
</template>

<script>
import BlogHome from '~/components/BlogHome.vue';

export default {
  middleware: 'blog-index-redirect',
  components: {
    BlogHome,
  },
  validate({ params }) {
    return /^\d+$/.test(params.id);
  },
  asyncData({ params }) {
    return {
      startPage: parseInt(params.id),
    };
  },
};
</script>
