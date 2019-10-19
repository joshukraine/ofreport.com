<template>
  <figure>
    <cld-image
      :public-id="publicId"
      :width="width"
      :height="height"
      :alt="alt"
      crop="scale"
      quality="auto"
    />
    <figcaption v-if="caption">
      {{ caption }}
    </figcaption>
  </figure>
</template>

<script>
export default {
  props: {
    publicId: {
      type: String,
      required: true,
    },
    width: {
      type: String,
      default: '',
    },
    height: {
      type: String,
      default: '',
    },
    alt: {
      type: String,
      required: true,
    },
    caption: {
      type: String,
      default: null,
    },
  },
};
</script>
