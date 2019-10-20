<template>
  <div>
    <h1>Home Page</h1>
    <p>Current page: {{ currentPage }}</p>

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

    <div class="paginator">
      <nuxt-link v-if="renderPrevLink" to="#">
        Prev
      </nuxt-link>
      <nuxt-link v-if="renderNextLink" to="#">
        Next
      </nuxt-link>
    </div>
  </div>
</template>

<script>
const perPage = 3;

export default {
  props: {
    allArticles: {
      type: Array,
      required: true,
    },
    currentPage: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      articles: [],
    };
  },
  computed: {
    articleCount() {
      return this.allArticles.length;
    },
    pageCount() {
      return Math.ceil(this.articleCount / perPage);
    },
    renderNextLink() {
      return this.currentPage < this.pageCount;
    },
    renderPrevLink() {
      return this.currentPage > 1;
    },
  },
  mounted() {
    // Calculate the range of articles to display.
    const start = (this.currentPage - 1) * perPage;
    const end = start + perPage;

    // Select the articles for the current page.
    this.articles = this.allArticles.slice(start, end);
  },
};
</script>
