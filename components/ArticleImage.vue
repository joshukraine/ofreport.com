<template>
  <figure class="my-10 md:my-16" :class="{ 'image-border': border }">
    <cld-image :public-id="publicId">
      <cld-transformation :width="width"
                          :height="height"
                          :alt="caption"
                          crop="scale"
                          fetchFormat="auto"
                          quality="auto"
      />
    </cld-image>

    <!-- eslint-disable vue/no-v-html -->
    <figcaption v-if="caption"
                class="mt-2 mx-auto text-center font-semibold"
                :class="{ 'portrait-caption': height }"
                v-html="renderInlineMd(caption)"
    />
    <!-- eslint-enable vue/no-v-html -->
  </figure>
</template>

<script>
import markdownit from '~/mixins/markdownit';

export default {
  mixins: [
    markdownit,
  ],
  props: {
    publicId: {
      type: String,
      required: true,
    },
    width: {
      type: String,
      default: null,
    },
    height: {
      type: String,
      default: null,
    },
    caption: {
      type: String,
      default: null,
    },
    border: {
      type: Boolean,
      default: false,
    },
  },
};
</script>

<style>
figure img {
  @apply .mx-auto;
}

.portrait-caption {
  max-width: 576px;
}

.image-border img {
  @apply .border;
}
</style>
