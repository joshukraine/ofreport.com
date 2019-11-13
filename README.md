# OFReport.com

> Our family blog, documenting our work in Ukraine

![OFReport.com screenshot][screenshot]

## Overview

OFReport.com is a [Vue.js][vue] application built with [Nuxt.js][nuxt], and is deployed as a pre-generated static site on [Amazon S3][aws-s3]. In addition to Vue and Nuxt, several noteworthy supporting technologies have been used, including the following:

* [Tailwind CSS][tailwind]
* [Purgecss][purgecss]
* [markdown-it][markdown-it]
* [frontmatter-markdown-loader][fml]
* [Cloudinary][cloudinary]
* [Vuelidate][vuelidate]
* [vuejs-paginate][vuejs-paginate]
* [gulp-awspublish][gulp-awspublish]

## Requirements

* [Node >= 10.x][node]
* [Yarn 1.x][yarn]
* [Gulp 4.x][gulp]

## Setup

To get started, clone/fork the repo, cd into it, and install the dependencies.

``` bash
$ yarn install
```

## Development

Nuxt uses [Webpack as its build tool][nuxt-assets], and is also pre-configured for [hot module replacement][hmr]. To begin, start the development server on `localhost:3000`:

```bash
$ yarn dev
```

## Static Build

In addition to deploying server-rendered apps, Nuxt also works great as a [static site generator][static-gen]. That's how we're using it here. To pre-render the entire site as static HTML, CSS, and JavaScript files, run this command:

```bash
$ yarn generate
```

## Local HTTP Server

Sometimes in development it can be helpful to run the statically generated site with a local web server, simulating a production environment. I have found [http-server][] to be a great choice. Here's how I build and serve the static site on my local machine.

First, install http-server globally if you don't already have it.

```bash
$ npm install http-server -g
```

Next, build the site as explained in the previous section.

```bash
$ yarn generate
```

Finally, move into the `dist/` folder and start the server.

```bash
$ cd dist/
$ http-server -p 8080
```

Visit `http://localhost:8080` and check out the site!

The generated site will be output to the `dist/` folder.

## Environment-specific Builds

Nuxt allows you to [define environment variables][env-property] which can be accessed at compile time by calling `process.env.YOUR_VARIABLE`. This is particularly useful for generating builds with specifics that differ between, for example, production and staging environments.

To generate a production build, run:

```bash
$ APP_ENV=production yarn generate
```

This will, among other things, set the robots meta tag to `index,follow`. If `APP_ENV` is set to anything else, the robots tag will be set to `noindex,nofollow`.

## Deployment

My preferred deployment solution for static sites is [Amazon S3][aws-s3]. It's super cheap, and provides lots of nice extras like a CDN with [CloudFront][aws-cloudfront] and a [free SSL certificate][aws-ssl]. The Nuxt docs provide a detailed guide to [deployment with S3 + Cloudfront][nuxt-s3-deploy].

Individual deploys are handled with the `bin/deploy` script, which calls the `gulp deploy` task provided by [gulp-awspublish][gulp-awspublish].  The `bin/deploy` script expects the environment to be passed as an argument.

```bash
# Deploy to development
$ bin/deploy dev

# Deploy to production
$ bin/deploy prod
```

For more information on deployment with Nuxt, [visit their FAQ page][nuxt-s3-deploy].

## Code Style and Linting

Project-specific JavaScript conforms to the [Airbnb][airbnb] code style.

JS linting is done with ESLint and extended with [eslint-plugin-vue][eslint-vue] and [eslint-config-airbnb-base][eslint-config-airbnb-base].

CSS linting is done with [stylelint][stylelint].

I use [Neovim][neovim] as my editor along with the [ALE][ale] plugin for asynchronous linting.

## Legal

Copyright © 2019 Joshua and Kelsie Steele. Software is licensed under [MIT][license].

[airbnb]: https://github.com/airbnb/javascript
[ale]: https://github.com/w0rp/ale
[aws-cloudfront]: https://aws.amazon.com/cloudfront/
[aws-s3]: https://aws.amazon.com/getting-started/projects/host-static-website/
[aws-ssl]: https://aws.amazon.com/blogs/aws/new-aws-certificate-manager-deploy-ssltls-based-apps-on-aws/
[cloudinary]: https://cloudinary.com/invites/lpov9zyyucivvxsnalc5/ck3hvrdcnvaeftjds7ep
[env-property]: https://nuxtjs.org/api/configuration-env#the-env-property
[eslint-config-airbnb-base]: https://yarnpkg.com/en/package/eslint-config-airbnb-base
[eslint-vue]: https://yarnpkg.com/en/package/eslint-plugin-vue
[fml]: https://hmsk.github.io/frontmatter-markdown-loader/
[gulp-awspublish]: https://yarnpkg.com/en/package/gulp-awspublish
[gulp]: https://yarnpkg.com/en/package/gulp
[hmr]: https://webpack.js.org/concepts/hot-module-replacement/
[http-server]: https://yarnpkg.com/en/package/http-server
[license]: https://github.com/joshukraine/ofreport.com/blob/master/LICENSE
[markdown-it]: https://yarnpkg.com/en/package/markdown-it
[neovim]: https://neovim.io/
[node]: https://nodejs.org/en/
[nuxt-assets]: https://nuxtjs.org/guide/assets
[nuxt-faq]: https://nuxtjs.org/faq
[nuxt-s3-deploy]: https://nuxtjs.org/faq/deployment-aws-s3-cloudfront
[nuxt]: https://nuxtjs.org/
[purgecss]: https://www.purgecss.com/
[screenshot]: https://res.cloudinary.com/dnkvsijzu/image/upload/bo_1px_solid_rgb:e2e8f0,c_scale,f_auto,q_auto,w_1000/v1573625059/OFReport/assets/ofreport.com_screenshot_c8ethn.png
[static-gen]: https://www.staticgen.com/nuxt
[stylelint]: https://stylelint.io/
[tailwind]: https://tailwindcss.com/
[vue]: https://vuejs.org/
[vuejs-paginate]: https://yarnpkg.com/en/package/vuejs-paginate
[vuelidate]: https://monterail.github.io/vuelidate/
[yarn]: https://yarnpkg.com/en/docs/install
