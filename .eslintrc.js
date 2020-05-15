/* eslint-disable max-len */

module.exports = {
  root: true,
  env: {
    browser: true,
    es6: true,
  },
  extends: [
    // https://github.com/airbnb/javascript
    'airbnb-base',

    // https://eslint.vuejs.org/rules/
    'plugin:vue/essential',

    // https://prettier.io/docs/en/integrating-with-linters.html#use-eslint-to-run-prettier
    'plugin:prettier/recommended',
  ],
  globals: {
    Atomics: 'readonly',
    SharedArrayBuffer: 'readonly',
  },
  parserOptions: {
    parser: 'babel-eslint',
    ecmaVersion: 2018,
    sourceType: 'module',
  },
  plugins: ['vue'],
  settings: {
    'import/core-modules': ['vue'],
  },
  rules: {
    // https://prettier.io/docs/en/integrating-with-linters.html#eslint
    'prettier/prettier': 'error',

    // Allow unresolved imports
    // https://github.com/nuxt/eslint-config/blob/master/packages/eslint-config/index.js
    'import/no-unresolved': 'off',

    // https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/extensions.md
    'import/extensions': [
      'error',
      'never',
      {
        vue: 'always',
        json: 'always',
      },
    ],

    // https://eslint.org/docs/rules/max-len
    // https://github.com/vuejs/eslint-plugin-vue/issues/731
    'max-len': 'off',

    // https://eslint.org/docs/rules/radix
    radix: ['error', 'as-needed'],

    // https://eslint.org/docs/rules/no-param-reassign
    'no-param-reassign': 'off',

    // Allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'warn',

    // https://github.com/vuejs/eslint-plugin-vue/blob/master/docs/rules/max-attributes-per-line.md
    'vue/max-attributes-per-line': [
      'error',
      {
        singleline: 2,
        multiline: {
          max: 1,
          allowFirstLine: true,
        },
      },
    ],
    'vue/attribute-hyphenation': [
      'error',
      'always',
      {
        ignore: ['fetchFormat'],
      },
    ],
  },
};
