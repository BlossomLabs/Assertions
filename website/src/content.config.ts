import { docsLoader } from "@astrojs/starlight/loaders";
import { docsSchema } from "@astrojs/starlight/schema";
import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

export const collections = {
  docs: defineCollection({ loader: docsLoader(), schema: docsSchema() }),
  // One entry per release, named after a protecting beast. `status` is
  // "upcoming" until the release ships; `date` is only set once it has.
  // "in-progress" (being worked on) and "planned" (not started) entries stay
  // in the repo but are not published: the site builds no card or page for
  // them (see PUBLISHED in src/lib/releases.ts).
  releases: defineCollection({
    loader: glob({ pattern: "*.md", base: "./src/content/releases" }),
    schema: z.object({
      codename: z.string(),
      version: z.string(),
      status: z.enum(["released", "upcoming", "in-progress", "planned"]),
      date: z.string().optional(),
      summary: z.string(),
      banner: z.enum(["argos", "byakko", "cerberus", "dharmapala", "erinyes", "fafnir", "genbu", "haetae", "issitoq", "janus"]),
      order: z.number(),
    }),
  }),
};
