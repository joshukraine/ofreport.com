<template>
  <article class="mb-8 md:mb-12">
    <PageHeader title="How to Donate" />

    <section class="container max-w-2xl mx-auto mt-6 sm:mt-8 md:mt-10 lg:mt-12">
      <DynamicMarkdown
        :render-fn="renderFn"
        :static-render-fns="staticRenderFns"
      />
    </section>
  </article>
</template>

<script>
import DynamicMarkdown from '~/components/DynamicMarkdown.vue';
import PageHeader from '~/components/PageHeader.vue';

export default {
  components: {
    DynamicMarkdown,
    PageHeader,
  },
  data() {
    return {
      description: 'If you would like to make a financial contribution, please choose from one of the options below. We are grateful for your kindness and generosity!',
      title: 'Donate',
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
    const page = await import('~/content/pages/donate.md');
    return {
      renderFn: page.vue.render,
      staticRenderFns: page.vue.staticRenderFns,
    };
  },
};
</script>
