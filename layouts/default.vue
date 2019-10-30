<template>
  <div>
    <TheNavbar />
    <main class="pt-16 md:pt-20">
      <nuxt />
    </main>
    <TheFooter />
  </div>
</template>

<script>
import TheNavbar from '~/components/TheNavbar';
import TheFooter from '~/components/TheFooter.vue';

export default {
  components: {
    TheNavbar,
    TheFooter,
  },
};
</script>
