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
          <h3 class="mt-0 md:text-3xl leading-none">
            {{ labelYear }}
          </h3>
        </div>
        <div>
          <ul class="ml-6 pdf-issues">
            <li v-for="issueYear in archives[labelYear]"
                :key="issueYear.file"
                class="text-base sm:text-xl leading-tight mb-2 md:mb-4 last:mb-0"
            >
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
      description: 'Since 2003, we have published a newsletter called Overseas Field Report. If you’re interested in reading the history of our ministry overseas, you’ve come to the right place!',
      title: 'Archives',
      years: [],
    };
  },
  head() {
    return {
      title: this.title,
      meta: [
        { hid: 'description', name: 'description', content: this.description },
        { hid: 'og:title', property: 'og:title', content: this.title },
        { hid: 'og:description', property: 'og:description', content: this.description },
        { hid: 'twitter:title', name: 'twitter:title', content: this.title },
        { hid: 'twitter:description', name: 'twitter:description', content: this.description },
      ],
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

<style>
.pdf-issues > li:before {
  background-image: url("data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgNjQwIDUxMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBkPSJNNTM3LjYgMjI2LjZjNC4xLTEwLjcgNi40LTIyLjQgNi40LTM0LjYgMC01My00My05Ni05Ni05Ni0xOS43IDAtMzguMSA2LTUzLjMgMTYuMkMzNjcgNjQuMiAzMTUuMyAzMiAyNTYgMzJjLTg4LjQgMC0xNjAgNzEuNi0xNjAgMTYwIDAgMi43LjEgNS40LjIgOC4xQzQwLjIgMjE5LjggMCAyNzMuMiAwIDMzNmMwIDc5LjUgNjQuNSAxNDQgMTQ0IDE0NGgzNjhjNzAuNyAwIDEyOC01Ny4zIDEyOC0xMjggMC02MS45LTQ0LTExMy42LTEwMi40LTEyNS40em0tMTMyLjkgODguN0wyOTkuMyA0MjAuN2MtNi4yIDYuMi0xNi40IDYuMi0yMi42IDBMMTcxLjMgMzE1LjNjLTEwLjEtMTAuMS0yLjktMjcuMyAxMS4zLTI3LjNIMjQ4VjE3NmMwLTguOCA3LjItMTYgMTYtMTZoNDhjOC44IDAgMTYgNy4yIDE2IDE2djExMmg2NS40YzE0LjIgMCAyMS40IDE3LjIgMTEuMyAyNy4zeiIgZmlsbD0iI0U1M0UzRSIvPgo8L3N2Zz4K");
  background-position: center;
  background-repeat: no-repeat;
  content: "";
  display: block;
  float: left;
  height: 1em;
  margin-left: -1.3em;
  margin-top: 2px;
  width: 1em;
}

@screen sm {
  .pdf-issues > li:before {
    margin-left: -1.5em;
    margin-top: 3px;
  }
}
</style>
