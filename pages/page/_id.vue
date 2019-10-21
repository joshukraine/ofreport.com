<template>
  <div>
    <BlogHome :start-page="startPage" />
  </div>
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
    const startPage = parseInt(params.id);

    return {
      startPage,
    };
  },
};
</script>
