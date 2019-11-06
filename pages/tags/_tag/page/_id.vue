<template>
  <article>
    <TagHome :start-page="startPage" />
  </article>
</template>

<script>
import TagHome from '~/components/TagHome.vue';

export default {
  middleware: 'tag-index-redirect',
  components: {
    TagHome,
  },
  validate({ params }) {
    return /^\d+$/.test(params.id);
  },
  asyncData({ params }) {
    return {
      startPage: parseInt(params.id),
    };
  },
};
</script>
