<template>
  <div style="background: linear-gradient(to bottom, #1f415c 0%, #0f2847 100%);">
    <section class="alpha bg-cover bg-top sm:bg-left-top flex items-center sm:p-10 md:bg-left lg:bg-top">
      <div class="container pb-10 sm:pb-0 md:py-24">
        <div class="flex justify-end pt-16 sm:pt-32 md:pt-0 lg:px-10">
          <div class="text-center px-8 md:w-2/5 md:px-0">
            <img class="w-full" src="~/assets/svg/josh-and-kels.svg">
            <p class="mt-2 mb-8 md:mb-12 text-white text-base font-header">
              Est. 2004
            </p>
            <p class="mb-8 text-white text-lg md:text-xl md:mb-12">
              We live in Ukraine where we strive to tell others about God's gift of
              eternal life through <span class="whitespace-no-wrap">Jesus Christ.</span>
            </p>
            <nuxt-link to="/family/" class="btn btn-lg btn-blue font-header">
              Meet our Family
            </nuxt-link>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.alpha {
  background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_640/v1571750972/OFReport/assets/joshandkels-OFReport.com-cover-mobile_wry9lu.jpg");
  min-height: 100vh;
}

@screen sm {
  .alpha {
    background-image: url("https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto:best,w_2000/v1571770785/OFReport/assets/joshandkels-OFReport.com-cover_hrc85f.jpg");
    min-height: 70vh;
  }
}
</style>
