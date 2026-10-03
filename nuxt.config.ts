// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2026-10-01',
  devtools: { enabled: process.env.NODE_ENV !== 'production' },
  modules: ['@nuxt/ui', '@nuxt/eslint'],
  css: ['~/assets/css/main.css'],
  // The site is a static `nuxt generate` build served by Firebase Hosting (.output/public).
  ssr: true,
})
