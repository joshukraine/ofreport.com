<template>
  <div>
    <TagHome :start-page="startPage" />
  </div>
</template>

<script>
import TagHome from '~/components/TagHome.vue';

export default {
  components: {
    TagHome,
  },
  validate({ params }) {
    return /^\d+$/.test(params.id);
  },
  asyncData({ params }) {
    const startPage = parseInt(params.id);

    return {
      startPage,
    };
  },
};
</script>
