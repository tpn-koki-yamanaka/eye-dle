import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => {
  return c.json([
    { id: 1, name: "Alice" },
    { id: 2, name: "Bob" },
  ]);
});

export default app;
