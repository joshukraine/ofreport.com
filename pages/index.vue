<template>
  <div>
    <BlogHome :start-page="1" />
  </div>
</template>

<script>
import BlogHome from '~/components/BlogHome.vue';

export default {
  components: {
    BlogHome,
  },
};
</script>
