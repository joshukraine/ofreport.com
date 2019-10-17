<template>
  <div>
    <h1>Blog Post</h1>
    <p>This is a blog post page.</p>
    <nuxt-link to="/">
      Home
    </nuxt-link>
    <!-- eslint-disable-next-line vue/no-v-html -->
    <div class="content" v-html="article.html" />
  </div>
</template>

<script>
export default {
  async asyncData({ params }) {
    try {
      const article = await import(`~/content/articles/${params.slug}.md`);

      return {
        article,
      };
    } catch (error) {
      console.debug(error);
      return false;
    }
  },
};
</script>
