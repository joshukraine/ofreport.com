<template>
  <article class="mb-8 md:mb-12">
    <section
      class="bg-top bg-cover border-b family min-h-250 xs:min-h-350 sm:min-h-450 md:min-h-500 lg:min-h-700 xl:min-h-900 xl:h-3/4-vh"
    ></section>

    <section class="container max-w-3xl mx-auto">
      <p class="mt-2 text-sm font-semibold text-center sm:text-base">
        Pleased to meet you! We're the Steele Family:<br />
        Joshua, Kelsie, Abigail, Rebekah, Hosanna, Kathryn, David, and Mia
      </p>
    </section>

    <section class="container max-w-3xl mx-auto mt-8 sm:mt-12 md:mt-16">
      <DynamicMarkdown dir="pages" slug="family" />
    </section>
  </article>
</template>

<script>
import DynamicMarkdown from '~/components/DynamicMarkdown.vue';

export default {
  components: {
    DynamicMarkdown,
  },
  data() {
    return {
      description:
        'Joshua and Kelsie are missionaries enjoying life as best friends, serving their Savior, and raising up their children to honor Him.',
      image:
        'https://res.cloudinary.com/dnkvsijzu/image/upload/c_fill,f_auto,h_630,q_auto:best,w_1200/v1572346054/OFReport/assets/steele-family-2018-12-6_sdixdx.jpg',
      title: 'The Steele Family',
    };
  },
  head() {
    return {
      title: this.title,
      meta: [
        { hid: 'description', name: 'description', content: this.description },
        { hid: 'og:image', property: 'og:image', content: this.image },
        { hid: 'og:title', property: 'og:title', content: this.title },
        { hid: 'og:image:width', property: 'og:image:width', content: '1200' },
        { hid: 'og:image:height', property: 'og:image:height', content: '630' },
        {
          hid: 'og:description',
          property: 'og:description',
          content: this.description,
        },
        { hid: 'twitter:title', name: 'twitter:title', content: this.title },
        {
          hid: 'twitter:description',
          name: 'twitter:description',
          content: this.description,
        },
        { hid: 'twitter:image', name: 'twitter:image', content: this.image },
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
  background-image: url('https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_768/v1607358340/OFReport/assets/steeles-fall-2020_mcp242.jpg');
}

@screen xs {
  .family {
    background-image: url('https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_1024/v1607358340/OFReport/assets/steeles-fall-2020_mcp242.jpg');
  }
}

@screen md {
  .family {
    background-image: url('https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_1500/v1607358340/OFReport/assets/steeles-fall-2020_mcp242.jpg');
  }
}

@screen lg {
  .family {
    background-image: url('https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_2000/v1607358340/OFReport/assets/steeles-fall-2020_mcp242.jpg');
  }
}

@screen xl {
  .family h1 {
    font-size: 5rem;
  }
}
</style>
