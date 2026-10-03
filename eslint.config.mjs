// @ts-check
import withNuxt from './.nuxt/eslint.config.mjs'

export default withNuxt({
  rules: {
    // Pages are single-word by convention (index.vue).
    'vue/multi-word-component-names': 'off',
  },
})
