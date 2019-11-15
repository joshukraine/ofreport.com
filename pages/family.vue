<template>
  <article class="mb-8 md:mb-12">
    <section class="family border-b bg-cover bg-center min-h-250 xs:min-h-350 sm:min-h-450 md:min-h-500 lg:min-h-600 xl:min-h-700 xl:h-3/4-vh">
      <section class="pt-4 xs:pt-6 sm:pt-6 md:pt-8 lg:pt-10 lg:pb-12 text-center">
        <h1 class="text-white text-3xl xs:text-4xl sm:text-5xl lg:text-6xl">
          Pleased to meet you!
        </h1>
      </section>
    </section>

    <section class="container max-w-3xl mx-auto">
      <p class="mt-2 text-center text-sm sm:text-base font-semibold">
        The Steele Family<br>
        Joshua, Kelsie, Abigail, Rebekah, Hosanna, Kathryn, David, and
        <nuxt-link to="/blog/2019-10-14-meet-mia/">
          Mia (not pictured)
        </nuxt-link>
      </p>
    </section>

    <section class="container max-w-3xl mx-auto mt-8 sm:mt-12 md:mt-16">
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
    const page = await import('~/content/pages/family.md');
    return {
      renderFn: page.vue.render,
      staticRenderFns: page.vue.staticRenderFns,
    };
  },
  data() {
    return {
      description: 'Joshua and Kelsie are missionaries enjoying life as best friends, serving their Savior, and raising up their children to honor Him.',
      title: 'The Steele Family',
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
};
</script>

<style scoped>
.steele-bio img {
  @apply rounded-lg;
}

.family {
  background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_768/v1573152683/OFReport/assets/family-2018-top-fade_ksxx7v.jpg");
}

@screen xs {
  .family {
    background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_1024/v1573152683/OFReport/assets/family-2018-top-fade_ksxx7v.jpg");
  }
}

@screen md {
  .family {
    background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_1500/v1573152683/OFReport/assets/family-2018-top-fade_ksxx7v.jpg");
  }
}

@screen lg {
  .family {
    background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_2000/v1573152683/OFReport/assets/family-2018-top-fade_ksxx7v.jpg");
  }
}

@screen xl {
  .family h1 {
    font-size: 5rem;
  }
}
</style>
