<template>
  <article class="mb-8 md:mb-12">
    <PageHeader title="We live to serve<br />Jesus Christ." :html="true" />

    <section class="container text-center max-w-2xl mx-auto -mt-4">
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
      description: 'Our highest purpose in life is to follow our Savior, the Lord Jesus Christ. We are raising our family in Ukraine, and striving to share the Gospel with those around us. If you’d like to learn more about how we minister, read on!',
      title: 'Ministry',
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
    const page = await import('~/content/pages/ministry.md');
    return {
      renderFn: page.vue.render,
      staticRenderFns: page.vue.staticRenderFns,
    };
  },
};
</script>
