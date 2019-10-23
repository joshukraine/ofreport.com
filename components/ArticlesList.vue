<template>
  <div class="container border">
    <div class="max-w-3xl mx-auto md:flex md:flex-wrap border">
      <div v-for="article in articles"
           :key="article.basename"
           class="md:w-1/2 mt-8"
      >
        <div class="md:mx-4 p-4 h-full flex flex-col justify-between bg-white rounded-lg shadow-md">
          <div>
            <h2 class="my-0 leading-none">
              {{ article.title }}
            </h2>
            <p class="text-sm mt-1">
              <span>{{ article.author }}</span>
              <span>&middot; {{ article.date }}</span>
            </p>
            <div v-if="article.cover" class="-mx-4">
              <card-image :article-cover="article.cover"
                          width="610"
                          :alt="article.caption"
              />
            </div>
            <p>{{ article.preview }}</p>
          </div>
          <p>
            <nuxt-link :to="`/blog/${article.basename}`">
              Read more
            </nuxt-link>
          </p>
        </div>
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
import CardImage from '~/components/CardImage.vue';

const perPage = parseInt(process.env.perPage);

export default {
  components: {
    CardImage,
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
