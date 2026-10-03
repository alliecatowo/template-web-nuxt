<script setup lang="ts">
import { greet } from '~/utils/greet'

useSeoMeta({ title: 'template-web-nuxt', description: 'Nuxt 4 web app template: Nuxt UI, ESLint and Prettier, vitest, Firebase Hosting, mise, lefthook, CI and a VitePress docs site.' })
const message = greet('world')
</script>

<template>
  <UContainer class="py-16">
    <h1 class="text-3xl font-semibold">template-web-nuxt</h1>
    <p class="mt-2 text-muted">Nuxt 4 web app template: Nuxt UI, ESLint and Prettier, vitest, Firebase Hosting, mise, lefthook, CI and a VitePress docs site.</p>
    <UButton class="mt-6" icon="i-lucide-sparkles" :label="message" />
  </UContainer>
</template>
