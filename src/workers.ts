import { startWorkers } from "./workers/index.js";

async function main() {
  await startWorkers();
  console.info("ShashinMori workers started");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
