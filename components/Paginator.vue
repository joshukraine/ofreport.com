<template>
  <div>
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
export default {
  props: {
    articleCount: {
      type: Number,
      required: true,
    },
    perPage: {
      type: Number,
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
      page: null,
    };
  },
  computed: {
    pageCount() {
      return Math.ceil(this.articleCount / this.perPage);
    },
    paginatedRoot() {
      return this.rootSegment ? `/${this.rootSegment}` : '';
    },
  },
  mounted() {
    // Set the current page.
    this.page = this.startPage;
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