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

<style>
.pdf-issues > li:before {
  background-image: url("data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMzg0IDUxMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBkPSJNMTgxLjkgMjU2LjFjLTUtMTYtNC45LTQ2LjktMi00Ni45IDguNCAwIDcuNiAzNi45IDIgNDYuOXptLTEuNyA0Ny4yYy03LjcgMjAuMi0xNy4zIDQzLjMtMjguNCA2Mi43IDE4LjMtNyAzOS0xNy4yIDYyLjktMjEuOS0xMi43LTkuNi0yNC45LTIzLjQtMzQuNS00MC44ek04Ni4xIDQyOC4xYzAgLjggMTMuMi01LjQgMzQuOS00MC4yLTYuNyA2LjMtMjkuMSAyNC41LTM0LjkgNDAuMnpNMjQ4IDE2MGgxMzZ2MzI4YzAgMTMuMy0xMC43IDI0LTI0IDI0SDI0Yy0xMy4zIDAtMjQtMTAuNy0yNC0yNFYyNEMwIDEwLjcgMTAuNyAwIDI0IDBoMjAwdjEzNmMwIDEzLjIgMTAuOCAyNCAyNCAyNHptLTggMTcxLjhjLTIwLTEyLjItMzMuMy0yOS00Mi43LTUzLjggNC41LTE4LjUgMTEuNi00Ni42IDYuMi02NC4yLTQuNy0yOS40LTQyLjQtMjYuNS00Ny44LTYuOC01IDE4LjMtLjQgNDQuMSA4LjEgNzctMTEuNiAyNy42LTI4LjcgNjQuNi00MC44IDg1LjgtLjEgMC0uMS4xLS4yLjEtMjcuMSAxMy45LTczLjYgNDQuNS01NC41IDY4IDUuNiA2LjkgMTYgMTAgMjEuNSAxMCAxNy45IDAgMzUuNy0xOCA2MS4xLTYxLjggMjUuOC04LjUgNTQuMS0xOS4xIDc5LTIzLjIgMjEuNyAxMS44IDQ3LjEgMTkuNSA2NCAxOS41IDI5LjIgMCAzMS4yLTMyIDE5LjctNDMuNC0xMy45LTEzLjYtNTQuMy05LjctNzMuNi03LjJ6TTM3NyAxMDVMMjc5IDdjLTQuNS00LjUtMTAuNi03LTE3LTdoLTZ2MTI4aDEyOHYtNi4xYzAtNi4zLTIuNS0xMi40LTctMTYuOXptLTc0LjEgMjU1LjNjNC4xLTIuNy0yLjUtMTEuOS00Mi44LTkgMzcuMSAxNS44IDQyLjggOSA0Mi44IDl6IiBmaWxsPSIjRTUzRTNFIi8+Cjwvc3ZnPgo=");
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
