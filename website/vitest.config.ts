/// <reference types="vitest/config" />
import { getViteConfig } from "astro/config";

// The tests import the builder modules, which resolve every @evmcrispr/*
// specifier to the vendored checkout through the Astro config's Vite
// aliases (scripts/evmcrispr-sources.mjs). getViteConfig applies that
// config, so a test sees exactly what the site bundles.
export default getViteConfig({
  test: {
    include: ["src/**/__tests__/**/*.test.{ts,tsx}"],
    // Logic tests run in node. Component tests (*.test.tsx) opt into a DOM
    // with a `// @vitest-environment jsdom` line at the top of the file;
    // the setup file does nothing outside one.
    environment: "node",
    setupFiles: ["src/test/setup-dom.ts"],
  },
});
