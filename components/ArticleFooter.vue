<template>
  <section class="my-8 md:my-12">
    <div class="max-w-lg mx-auto px-6">
      <img src="~/assets/svg/to-god-be-the-glory.svg" alt="To God be the Glory">
    </div>
    <hr class="border-t-4 my-8">
    <div class="max-w-lg mx-auto">
      <h3 class="mt-0 text-center text-2xl md:text-3xl">
        Like what you're reading?<br>Let's keep in touch!
      </h3>
      <div class="mt-6">
        <McSubscribeForm />
      </div>
    </div>
  </section>
</template>

<script>
import McSubscribeForm from '~/components/McSubscribeForm.vue';

export default {
  components: {
    McSubscribeForm,
  },
};
</script>
