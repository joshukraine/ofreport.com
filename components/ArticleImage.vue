<template>
  <client-only>
    <figure
      class="my-10 md:my-16 rounded-corners"
      :class="{ 'image-border': border }"
    >
      <cld-image
        :public-id="publicId"
        loading="lazy"
        :width="width"
        :height="height"
        :alt="caption"
      >
        <cld-transformation
          :width="width"
          :height="height"
          crop="scale"
          fetchFormat="auto"
          quality="auto"
        />
      </cld-image>
      <figcaption
        v-if="caption"
        class="mx-auto mt-2 font-serif font-semibold text-center"
        :class="{ 'portrait-caption': height }"
        v-html="renderInlineMd(caption)"
      />
    </figure>
  </client-only>
</template>

<script>
import markdownit from '~/mixins/markdownit';

export default {
  mixins: [markdownit],
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

.rounded-corners img {
  @apply .rounded;
}
</style>
