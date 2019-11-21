<template>
  <article class="donate pb-8 md:pb-20">
    <PageHeader title="How to Donate" />

    <section class="container max-w-2xl mx-auto -mt-4">
      <DynamicMarkdown dir="pages" slug="donate" />
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
};
</script>

<style>
@screen sm {
  .donate {
    background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto,w_2000/v1573039527/OFReport/assets/full-family-bg-fade_b2lc3m.jpg");
    background-repeat: no-repeat;
    background-size: 100% auto;
  }
}
</style>
