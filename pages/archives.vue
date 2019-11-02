<template>
  <article class="mb-8 md:mb-12">
    <PageHeader title="Through the Years" />

    <section class="container max-w-2xl mx-auto mt-6 sm:mt-8 md:mt-10 lg:mt-12">
      <DynamicMarkdown
        :render-fn="renderFn"
        :static-render-fns="staticRenderFns"
      />
    </section>

    <section class="container max-w-2xl mx-auto mt-6 sm:mt-8 md:mt-10 lg:mt-12">
      <div v-for="labelYear in years"
           :key="labelYear"
           class="flex mb-6 sm:mb-8 last:mb-0 pb-6 sm:pb-8 last:pb-0 border-b last:border-b-0"
      >
        <div class="pr-4 sm:pr-6 md:pr-10">
          <h3 class="mt-0 md:text-3xl leading-tight">
            {{ labelYear }}
          </h3>
        </div>
        <div>
          <ul class="fa-ul">
            <li v-for="issueYear in archives[labelYear]"
                :key="issueYear.file"
                class="text-base sm:text-xl leading-tight mb-2 md:mb-4 last:mb-0"
            >
              <span class="fa-li text-red-600">
                <font-awesome-icon :icon="['fas', 'file-pdf']" fixed-width />
              </span>
              <a :href="cdnLink(issueYear.file)"
                 target="_blank"
                 rel="noopener noreferrer"
              >
                {{ issueYear.title }}
                <span class="whitespace-no-wrap">({{ issueYear.issue }})</span>
              </a>
            </li>
          </ul>
        </div>
      </div>
    </section>
  </article>
</template>

<script>
import DynamicMarkdown from '~/components/DynamicMarkdown.vue';
import PageHeader from '~/components/PageHeader.vue';
import archives from '~/data/archives.json';

export default {
  components: {
    DynamicMarkdown,
    PageHeader,
  },
  data() {
    return {
      archives: {},
      years: [],
    };
  },
  async asyncData() {
    const page = await import('~/content/pages/archives.md');
    return {
      renderFn: page.vue.render,
      staticRenderFns: page.vue.staticRenderFns,
    };
  },
  created() {
    this.archives = archives;
    this.years = Object.keys(archives).reverse();
  },
  methods: {
    cdnLink(file) {
      return `https://d21yo20tm8bmc2.cloudfront.net/ofr/${file}`;
    },
  },
};
</script>
