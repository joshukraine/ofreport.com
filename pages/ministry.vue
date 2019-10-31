<template>
  <article class="mb-8 md:mb-12">
    <section class="my-6 sm:my-8 lg:my-12 text-center">
      <h1 class="lg:text-6xl">
        We live to serve<br>Jesus Christ.
      </h1>
    </section>

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

export default {
  components: {
    DynamicMarkdown,
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
