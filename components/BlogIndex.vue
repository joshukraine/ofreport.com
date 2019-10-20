<template>
  <div>
    <h1>Home Page</h1>

    <div v-for="article in articles"
         :key="article.basename"
         class="markdown"
    >
      <h2>{{ article.title }}</h2>
      <p>{{ article.preview }}</p>
      <nuxt-link :to="'blog/' + article.basename">
        Read
      </nuxt-link>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    articles: {
      type: Array,
      required: true,
    },
  },
};
</script>
