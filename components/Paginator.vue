<template>
  <div class="my-6 sm:my-8 md:my-10 w-full">
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
  @apply .flex .justify-center .list-none;
}

.pagination > li > a {
  @apply .mx-1 .py-1 .px-2 .border .text-sm .text-blue-600 .rounded;
}

.pagination > li > a:hover {
  @apply .bg-gray-100;
}

.pagination .active > a,
.pagination .active > a:focus,
.pagination .active > a:hover {
  @apply .bg-blue-600 .border .border-blue-600 .text-white .cursor-default .outline-none;
}

.pagination .disabled > a,
.pagination .disabled > a:focus,
.pagination .disabled > a:hover {
  @apply .text-gray-400 .cursor-default .bg-gray-050 .outline-none;
}

.pagination .page-item {
  @apply .hidden;
}

@screen xs {
  .pagination .page-item {
    @apply .block;
  }
}

@screen sm {
  .pagination > li > a {
    @apply .mx-2 .py-2 .px-3 .text-base .font-normal;
  }
}

</style>
