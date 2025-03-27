import type { Config } from "tailwindcss";

export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#016973",
        secondary: "#4a6267",
        tertiary: "#515e7c",
        background: "#fbfdfd",
        erroe: "#ba1a1a"
      },
    },
  },
  plugins: [],
} satisfies Config;
