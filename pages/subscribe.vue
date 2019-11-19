<template>
  <article class="subscribe pb-8 md:pb-20">
    <PageHeader title="Subscribe" />

    <section class="container flex justify-between max-w-3xl">
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
        <div class="flex mb-6">
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
            <p class="mt-0 xs:text-lg">
              <em>Overseas Field Report</em> is our bi-monthly newsletter
              containing updates on our family and ministry here in Ukraine.
              We’d be tickled if you’d subscribe and pray for us!
            </p>
          </div>
        </div>
        <McSubscribeForm />
        <p>
          You can also access previous issues in our
          <nuxt-link to="/archives/">
            Archives.
          </nuxt-link>
        </p>

        <hr class="my-8">

        <p class="mt-0">
          Don't want to receive emails from us anymore?
        </p>
        <p>
          <a href="https://OFReport.us6.list-manage.com/unsubscribe?u=1e0c65850b60905f65b151819&id=97b9f6a559">Unsubscribe</a>
        </p>
      </div>
    </section>
  </article>
</template>

<script>
import McSubscribeForm from '~/components/McSubscribeForm.vue';
import PageHeader from '~/components/PageHeader.vue';

export default {
  components: {
    McSubscribeForm,
    PageHeader,
  },
};
</script>

<style scoped>
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
}
</style>
