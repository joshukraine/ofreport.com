<template>
  <article class="mb-8 md:mb-12">
    <PageHeader title="We live to serve<br />Jesus Christ." :html="true" />

    <section class="container text-center max-w-2xl mx-auto mt-6 sm:mt-8 md:mt-10 lg:mt-12">
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
  head() {
    return {
      title: 'Ministry',
      meta: [
        { hid: 'description', name: 'description', content: 'Our highest purpose in life is to follow our Savior, the Lord Jesus Christ. We are raising our family in Ukraine, and striving to share the Gospel with those around us. If you’d like to learn more about how we minister, read on!' },
      ],
    };
  },
  components: {
    DynamicMarkdown,
    PageHeader,
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
