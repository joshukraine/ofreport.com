<template>
  <div class="container">
    <div class="max-w-3xl mx-auto md:flex md:flex-wrap">
      <div v-if="isBlogHome" class="mt-6 md:mt-10 w-full">
        <ArticlePreview :article="featuredArticle" :featured="true" />
      </div>
      <div v-for="article in articles"
           :key="article.basename"
           class="mt-6 md:mt-10 md:w-1/2"
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
    isBlogHome() {
      return this.rootSegment === 'blog' && this.startPage === 1;
    },
    calculatedArticleRange() {
      if (this.rootSegment === 'blog') {
        return ((this.page - 1) * this.perPage) + 1;
      }
      return (this.page - 1) * this.perPage;
    },
  },
  mounted() {
    // Set the current page.
    this.page = this.startPage;

    // Calculate the range of articles to display.
    if (this.isBlogHome) {
      this.start = 1;
    } else {
      this.start = this.calculatedArticleRange;
    }
    const end = this.start + this.perPage;

    // Select the articles for the current page.
    this.articles = this.allArticles.slice(this.start, end);
  },
};
</script>
