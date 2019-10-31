<template>
  <div>
    <a v-if="external"
       :href="path"
       :class="bgStyle"
       class="article-button btn md:btn-lg"
       target="_blank"
       rel="noopener noreferrer"
    >
      {{ text }}
    </a>
    <nuxt-link v-else
               :to="path"
               :class="bgStyle"
               class="article-button btn md:btn-lg"
    >
      {{ text }}
    </nuxt-link>
  </div>
</template>

<script>
export default {
  props: {
    text: {
      type: String,
      required: true,
    },
    path: {
      type: String,
      default: '',
    },
    external: {
      type: Boolean,
      required: true,
    },
    outline: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    bgStyle() {
      return this.outline ? 'btn-blue-outline' : 'btn-blue';
    },
  },
};
</script>

<style scoped>
.article-button {
  @apply .my-8 .inline-block .text-sm;
}

@screen xs {
  .article-button {
    @apply .text-base;
  }
}
</style>
