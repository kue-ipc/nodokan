import js from "@eslint/js";
import tseslint from "typescript-eslint";
import globals from "globals";
import civet from "eslint-plugin-civet";
import { defineConfig } from "eslint/config";

export default defineConfig([
  // Enable recommended rules for all files
  // js.configs.recommended,
  {
    files: ['**/*.{mjs,mts}'],
    plugins: {js},
    extends: ["js/recommended"],
    languageOptions: {globals: globals.node},
  },
  {
    files: ['**/*.{js,ts}'],
    plugins: {js},
    extends: ["js/recommended"],
    languageOptions: {globals: globals.browser},
  },
  tseslint.configs.recommended,
  // Load plugin and enable processor for .civet files
  {
    files: ["**/*.civet"],
    plugins: {civet},
    processor: "civet/civet",
  },
]);
