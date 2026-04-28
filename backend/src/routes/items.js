import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => {
  return c.json([
    { id: 101, name: "Item A" },
    { id: 102, name: "Item B" },
  ]);
});

export default app;
