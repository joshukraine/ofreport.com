<template>
  <figure class="my-10 md:my-16">
    <cld-image :public-id="publicId">
      <cld-transformation :width="width"
                          :height="height"
                          :alt="caption"
                          crop="scale"
                          fetchFormat="auto"
                          quality="auto"
      />
    </cld-image>
    <figcaption v-if="caption"
                class="mt-2 mx-auto text-center font-semibold"
                :class="{ 'portrait-caption': height }"
    >
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
</style>
