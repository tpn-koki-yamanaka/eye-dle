import { serve } from "@hono/node-server";
import { Hono } from "hono";
import users from "./routes/users.js";
import items from "./routes/items.js";

const app = new Hono();

app.route("/api/users", users);
app.route("/api/items", items);

app.get("/api/hello", (c) => {
  return c.json({ message: "Hello from Hono backend!" });
});

const port = 8787;

console.log(`Backend server is running on http://localhost:${port}`);
serve({ fetch: app.fetch, port });
