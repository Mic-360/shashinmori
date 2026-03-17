import { config } from "./config/env.js";
import { buildServer } from "./server.js";
import { startWorkers } from "./workers/index.js";

async function main() {
  const app = await buildServer();

  if (process.env.START_WORKERS !== "false") {
    await startWorkers();
  }

  await app.listen({
    port: config.port,
    host: "0.0.0.0"
  });
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
