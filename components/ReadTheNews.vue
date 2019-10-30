<template>
  <section class="read-the-news bg-cover bg-center py-10 xs:px-4 xs:py-12 sm:px-8 md:px-16 md:py-20 lg:px-0 lg:py-24">
    <div class="container flex justify-between max-w-3xl">
      <figure class="ofr-cover hidden sm:block">
        <cld-image public-id="OFReport/assets/OFR-May-Jun-2018_gvz1ij.jpg">
          <cld-transformation width="200"
                              alt="Overseas Field Report"
                              crop="scale"
                              fetchFormat="auto"
                              quality="auto:best"
          />
        </cld-image>
      </figure>
      <div class="flex-1 sm:ml-6 md:ml-10 lg:ml-12">
        <div class="flex">
          <figure class="ofr-cover sm:hidden mr-4">
            <cld-image public-id="OFReport/assets/OFR-May-Jun-2018_gvz1ij.jpg">
              <cld-transformation width="100"
                                  alt="Overseas Field Report"
                                  crop="scale"
                                  fetchFormat="auto"
                                  quality="auto:best"
              />
            </cld-image>
          </figure>
          <div class="flex-1">
            <h2 class="mt-0">
              Read the News
            </h2>
            <p>
              <em>Overseas Field Report</em> is our bi-monthly newsletter
              containing updates on our family and ministry here in Ukraine.
              We’d be tickled if you’d subscribe and pray for us!
            </p>
          </div>
        </div>
        <McSubscribeForm />
        <p>
          You can also access previous issues in our
          <nuxt-link to="/archives">
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
.read-the-news {
  background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto,w_800/v1571750972/OFReport/assets/ofr-logo-faded-bg_n7difd.jpg");
}

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
}

@screen md {
  .ofr-cover img {
    width: inherit;
  }

  .read-the-news {
    background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto,w_1500/v1571750972/OFReport/assets/ofr-logo-faded-bg_n7difd.jpg");
  }
}

@screen lg {
  .read-the-news {
    background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto,w_2000/v1571750972/OFReport/assets/ofr-logo-faded-bg_n7difd.jpg");
  }
}
</style>
