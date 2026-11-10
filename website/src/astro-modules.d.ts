// `astro check` types `.astro` imports through its language server; plain
// `tsc` (editors, the vitest type pass) cannot read them. For a TypeScript
// file importing a component (the social cards render them), this gives it
// the type Astro gives every component. A module that does resolve, as every
// `.astro` file does under `astro check`, is never typed by this.
declare module "*.astro" {
  const Component: import("astro/runtime/server/index.js").AstroComponentFactory;
  export default Component;
}
