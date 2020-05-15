<template>
  <article class="pb-8 ministry md:pb-12">
    <PageHeader title="We live to serve<br />Jesus Christ." :html="true" />

    <section class="container max-w-2xl mx-auto -mt-4 text-center">
      <DynamicMarkdown dir="pages" slug="ministry" />
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
      description:
        'Our highest purpose in life is to follow our Savior, the Lord Jesus Christ. We are raising our family in Ukraine, and striving to share the Gospel with those around us. If you’d like to learn more about how we minister, read on!',
      title: 'Ministry',
    };
  },
  head() {
    return {
      title: this.title,
      meta: [
        { hid: 'description', name: 'description', content: this.description },
        { hid: 'og:title', property: 'og:title', content: this.title },
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
      ],
    };
  },
};
</script>

<style>
@screen sm {
  .ministry {
    background-image: url('https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto,w_2000/v1573039527/OFReport/assets/abby-beka-ministry-bg-fade_lwhwyj.jpg');
    background-repeat: no-repeat;
    background-size: 100% auto;
  }
}
</style>
