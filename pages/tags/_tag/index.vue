<template>
  <div>
    <TagHome :start-page="1" />
  </div>
</template>

<script>
import TagHome from '~/components/TagHome.vue';

export default {
  components: {
    TagHome,
  },
};
</script>
