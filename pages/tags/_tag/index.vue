<template>
  <article>
    <TagHome :start-page="1" />
  </article>
</template>

<script>
import TagHome from '~/components/TagHome.vue';

export default {
  components: {
    TagHome,
  },
};
</script>
