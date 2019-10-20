<template>
  <div>
    <h1>Home Page</h1>
    <p>Current page: {{ page }}</p>

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

    <paginate
      v-model="page"
      :page-count="pageCount"
      :click-handler="pageChangeHandle"
      :prev-text="'Prev'"
      :next-text="'Next'"
      :container-class="'pagination'"
      :page-class="'page-item'"
      :page-link-class="'page-link-item'"
      :prev-class="'prev-item'"
      :prev-link-class="'prev-link-item'"
      :next-class="'next-item'"
      :next-link-class="'next-link-item'"
      :break-view-class="'break-view'"
      :break-view-link-class="'break-view-link'"
      :first-last-button="true"
    />
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
    startPage: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      articles: [],
      page: null,
    };
  },
  computed: {
    articleCount() {
      return this.allArticles.length;
    },
    pageCount() {
      return Math.ceil(this.articleCount / perPage);
    },
  },
  mounted() {
    // Set the current page.
    this.page = this.startPage;

    // Calculate the range of articles to display.
    const start = (this.page - 1) * perPage;
    const end = start + perPage;

    // Select the articles for the current page.
    this.articles = this.allArticles.slice(start, end);
  },
  methods: {
    pageChangeHandle(pageNum) {
      if (pageNum === 1) {
        this.$nuxt.$router.push('/');
      } else {
        this.$nuxt.$router.push(`/page/${pageNum}`);
      }
    },
  },
};
</script>

<style>
.pagination {
  @apply .flex .mt-8;
}

.pagination > li > a {
  @apply .py-2 .px-4 .border;
}

.pagination .active {
  @apply .text-blue-500 .font-bold;
}
</style>
