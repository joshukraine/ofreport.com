<template>
  <section
    class="py-6 bg-center bg-cover read-the-news xs:px-4 xs:py-8 sm:py-12 sm:px-8 md:px-16 md:py-20 lg:px-0 lg:py-24"
  >
    <div class="container flex justify-between max-w-3xl">
      <figure class="hidden ofr-cover sm:block">
        <cld-image
          public-id="OFReport/assets/OFR-May-Jun-2018_gvz1ij.jpg"
          loading="lazy"
          width="200"
          alt="Overseas Field Report"
        >
          <cld-transformation
            width="200"
            crop="scale"
            fetchFormat="auto"
            quality="auto:best"
          />
        </cld-image>
      </figure>
      <div class="flex-1 sm:ml-6 md:ml-10 lg:ml-12">
        <div class="flex">
          <figure class="mr-4 ofr-cover sm:hidden">
            <cld-image
              public-id="OFReport/assets/OFR-May-Jun-2018_gvz1ij.jpg"
              width="100"
              alt="Overseas Field Report"
            >
              <cld-transformation
                width="100"
                crop="scale"
                fetchFormat="auto"
                quality="auto:best"
              />
            </cld-image>
          </figure>
          <div class="flex-1 mb-6 md:pr-6">
            <h2 class="mt-0">
              Read the News
            </h2>
            <p class="font-serif">
              <em>Overseas Field Report</em> is our bi-monthly newsletter
              containing updates on our family and ministry here in Ukraine.
              We’d be tickled if you’d subscribe and pray for us!
            </p>
          </div>
        </div>
        <McSubscribeForm />
        <p class="font-serif">
          You can also access previous issues in our
          <nuxt-link to="/archives/">
            Archives.
          </nuxt-link>
        </p>
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

<style>
.ofr-cover img {
  @apply shadow-md;
  width: 70px;
}

@screen xs {
  .ofr-cover img {
    @apply shadow-lg;
    width: 100px;
  }
}

@screen sm {
  .ofr-cover img {
    width: 150px;
  }

  .read-the-news {
    background-image: url('https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto,w_1024/v1571750972/OFReport/assets/ofr-logo-faded-bg_w6uvhk.jpg');
  }
}

@screen md {
  .ofr-cover img {
    width: inherit;
  }

  .read-the-news {
    background-image: url('https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto,w_2000/v1571750972/OFReport/assets/ofr-logo-faded-bg_w6uvhk.jpg');
  }
}
</style>
