<template>
  <div>
    <h1>Title: {{ fm.title }}</h1>
    <p>This is a blog post page.</p>
    <nuxt-link to="/">
      Home
    </nuxt-link>
    <!-- eslint-disable-next-line vue/no-v-html -->
    <div class="content" v-html="body" />
  </div>
</template>

<script>
export default {
  async asyncData({ params }) {
    try {
      const article = await import(`~/content/articles/${params.slug}.md`);

      return {
        fm: article.attributes, // frontmatter
        body: article.html,
      };
    } catch (error) {
      console.debug(error);
      return false;
    }
  },
};
</script>
