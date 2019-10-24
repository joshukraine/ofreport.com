<template>
  <div class="container">
    <div class="max-w-3xl mx-auto md:flex md:flex-wrap">
      <div v-if="isBlogHome" class="mt-8 w-full">
        <ArticlePreview :article="featuredArticle" :featured="true" />
      </div>
      <div v-for="article in articles"
           :key="article.basename"
           class="md:w-1/2 mt-8"
      >
        <ArticlePreview :article="article" :featured="false" />
      </div>
    </div>

    <paginate
      v-if="pageCount > 1"
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
import ArticlePreview from '~/components/ArticlePreview.vue';

const perPage = parseInt(process.env.perPage);

export default {
  components: {
    ArticlePreview,
  },
  props: {
    allArticles: {
      type: Array,
      required: true,
    },
    startPage: {
      type: Number,
      required: true,
    },
    rootSegment: {
      type: String,
      default: null,
    },
  },
  data() {
    return {
      articles: [],
      page: null,
      isBlogHome: false,
      start: 0,
    };
  },
  computed: {
    articleCount() {
      return this.allArticles.length;
    },
    pageCount() {
      return Math.ceil(this.articleCount / perPage);
    },
    paginatedRoot() {
      return this.rootSegment ? `/${this.rootSegment}` : '';
    },
    featuredArticle() {
      return this.allArticles[0];
    },
  },
  created() {
    if (this.$route.fullPath === '/blog/') {
      this.isBlogHome = true;
    }
  },
  mounted() {
    // Set the current page.
    this.page = this.startPage;

    // Calculate the range of articles to display.
    if (this.isBlogHome) {
      this.start = 1;
    } else {
      this.start = (this.page - 1) * perPage;
    }
    const end = this.start + perPage;

    // Select the articles for the current page.
    this.articles = this.allArticles.slice(this.start, end);
  },
  methods: {
    pageChangeHandle(pageNum) {
      if (pageNum === 1) {
        this.$nuxt.$router.push(`${this.paginatedRoot}/`);
      } else {
        this.$nuxt.$router.push(`${this.paginatedRoot}/page/${pageNum}`);
      }
    },
  },
};
</script>

<style>
.pagination {
  @apply .flex .mt-8 .list-none;
}

.pagination > li > a {
  @apply .py-2 .px-4 .border;
}

.pagination .active {
  @apply .text-blue-500 .font-bold;
}
</style>
