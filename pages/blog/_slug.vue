<template>
  <div>
    <h1>Title: {{ fm.title }}</h1>
    <p>This is a blog post page.</p>
    <nuxt-link to="/" class="text-red-500">
      Home
    </nuxt-link>

    <DynamicMarkdown
      :render-fn="renderFn"
      :static-render-fns="staticRenderFns"
    />
  </div>
</template>

<script>
import DynamicMarkdown from '~/components/DynamicMarkdown.vue';

export default {
  components: {
    DynamicMarkdown,
  },
  async asyncData({ params }) {
    try {
      const article = await import(`~/content/articles/${params.slug}.md`);
      return {
        fm: article.attributes, // frontmatter
        renderFn: article.vue.render,
        staticRenderFns: article.vue.staticRenderFns,
      };
    } catch (error) {
      return false;
    }
  },
};
</script>
