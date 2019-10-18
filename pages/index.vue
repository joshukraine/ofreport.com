<template>
  <div>
    <h1>Home Page</h1>
    <p>These are the articles:</p>

    <div v-for="article in articles"
         :key="article._path"
         class="markdown"
    >
      <h2>{{ article.title }}</h2>
      <p>{{ article.preview }}</p>
      <nuxt-link :to="article._path">
        Read
      </nuxt-link>
    </div>
  </div>
</template>

<script>
export default {
  async asyncData() {
    const context = await require.context('~/content/articles/', true, /\.md$/);

    const articles = await context.keys().slice(5, 10).map((key) => ({
      ...context(key).attributes,
      _path: `/blog/${key.replace('.md', '').replace('./', '')}`,
    }));

    return {
      articles: articles.reverse(),
    };
  },
};
</script>
