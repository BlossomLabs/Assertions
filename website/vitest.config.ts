/// <reference types="vitest/config" />
import { getViteConfig } from "astro/config";

// The tests import the builder modules, which resolve every @evmcrispr/*
// specifier to the vendored checkout through the Astro config's Vite
// aliases (scripts/evmcrispr-sources.mjs). getViteConfig applies that
// config, so a test sees exactly what the site bundles.
export default getViteConfig({
  test: {
    include: ["src/**/__tests__/**/*.test.ts"],
    environment: "node",
  },
});
