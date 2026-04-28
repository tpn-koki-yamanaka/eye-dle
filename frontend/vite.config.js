import { defineConfig } from "vite";
import { resolve } from "path";
import { glob } from "glob";

// src/pages 配下の index.html を自動的に見つけてエントリポイントに追加する
const pages = glob.sync("src/pages/**/index.html").reduce((acc, file) => {
  // src/pages/users/index.html -> users
  const name = file.replace(/src\/pages\/(.*)\/index\.html/, "$1");
  acc[name] = resolve(__dirname, file);
  return acc;
}, {
  main: resolve(__dirname, "index.html"),
});

export default defineConfig({
  build: {
    rollupOptions: {
      input: pages,
    },
  },
  server: {
    port: 5173,
    proxy: {
      "/api": {
        changeOrigin: true,
        target: "http://localhost:8787",
      },
    },
  },
});
