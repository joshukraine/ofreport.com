<template>
  <section class="py-4 border-t-4 border-b-4 sm:py-6" :class="marginClasses">
    <p
      v-if="download"
      class="m-0 font-bold text-center pdf-download sm:text-xl"
    >
      <a
        class="inline-block"
        :href="downloadLink"
        target="_blank"
        rel="noopener noreferrer"
      >
        Download PDF Newsletter
      </a>
    </p>

    <div v-else-if="link">
      <p class="m-0 font-bold text-center sm:text-xl">
        {{ content }}
      </p>
      <p class="font-bold text-center sm:text-xl">
        <template v-if="link.to">
          <nuxt-link :to="link.to">
            {{ link.name }}
          </nuxt-link>
        </template>
        <template v-if="link.href">
          <a
            class="inline-block"
            :href="link.href"
            target="_blank"
            rel="noopener noreferrer"
          >
            {{ link.name }}
          </a>
        </template>
      </p>
    </div>

    <p v-else class="m-0 font-bold text-center sm:text-xl">
      {{ content }}
    </p>
  </section>
</template>

<script>
export default {
  props: {
    content: {
      type: String,
      required: true,
    },
    download: {
      type: Boolean,
      default: false,
    },
    mt: {
      type: String,
      default: '12',
    },
    mb: {
      type: String,
      default: '12',
    },
    link: {
      type: Object,
      default: null,
    },
  },
  computed: {
    downloadLink() {
      const cdn = 'https://d21yo20tm8bmc2.cloudfront.net/ofr/';
      return cdn + this.content;
    },
    marginClasses() {
      return `mt-${this.mt} mb-${this.mb}`;
    },
  },
};
</script>

<style>
.pdf-download > a:before {
  background-image: url('data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgNjQwIDUxMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBkPSJNNTM3LjYgMjI2LjZjNC4xLTEwLjcgNi40LTIyLjQgNi40LTM0LjYgMC01My00My05Ni05Ni05Ni0xOS43IDAtMzguMSA2LTUzLjMgMTYuMkMzNjcgNjQuMiAzMTUuMyAzMiAyNTYgMzJjLTg4LjQgMC0xNjAgNzEuNi0xNjAgMTYwIDAgMi43LjEgNS40LjIgOC4xQzQwLjIgMjE5LjggMCAyNzMuMiAwIDMzNmMwIDc5LjUgNjQuNSAxNDQgMTQ0IDE0NGgzNjhjNzAuNyAwIDEyOC01Ny4zIDEyOC0xMjggMC02MS45LTQ0LTExMy42LTEwMi40LTEyNS40em0tMTMyLjkgODguN0wyOTkuMyA0MjAuN2MtNi4yIDYuMi0xNi40IDYuMi0yMi42IDBMMTcxLjMgMzE1LjNjLTEwLjEtMTAuMS0yLjktMjcuMyAxMS4zLTI3LjNIMjQ4VjE3NmMwLTguOCA3LjItMTYgMTYtMTZoNDhjOC44IDAgMTYgNy4yIDE2IDE2djExMmg2NS40YzE0LjIgMCAyMS40IDE3LjIgMTEuMyAyNy4zeiIgZmlsbD0iI0U1M0UzRSIvPgo8L3N2Zz4K');
  background-position: center;
  background-repeat: no-repeat;
  content: '';
  display: block;
  float: left;
  height: 1.3em;
  margin-left: -1.5em;
  margin-top: 1px;
  width: 1.3em;
}

@screen sm {
  .pdf-download > a:before {
    margin-left: -1.7em;
  }
}
</style>
