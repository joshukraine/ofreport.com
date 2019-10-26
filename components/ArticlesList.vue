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

      <Paginator :article-count="articleCount"
                 :start-page="startPage"
                 :root-segment="rootSegment"
                 :per-page="perPage"
      />
    </div>
  </div>
</template>

<script>
import ArticlePreview from '~/components/ArticlePreview.vue';
import Paginator from '~/components/Paginator.vue';

const perPage = parseInt(process.env.perPage);

export default {
  components: {
    ArticlePreview,
    Paginator,
  },
  props: {
    allArticles: {
      type: Array,
      required: true,
    },
    rootSegment: {
      type: String,
      default: null,
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
      isBlogHome: false,
      start: 0,
      perPage,
    };
  },
  computed: {
    articleCount() {
      return this.allArticles.length;
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
      this.start = (this.page - 1) * this.perPage;
    }
    const end = this.start + this.perPage;

    // Select the articles for the current page.
    this.articles = this.allArticles.slice(this.start, end);
  },
};
</script>
