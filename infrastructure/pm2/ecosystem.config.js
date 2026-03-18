const path = require("path");

const projectRoot = path.resolve(__dirname, "..", "..");

module.exports = {
  apps: [
    {
      name: "shashinmori-api",
      cwd: projectRoot,
      script: path.join(projectRoot, "dist", "index.js"),
      env_file: path.join(projectRoot, ".env"),
      env: {
        START_WORKERS: "false"
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "400M"
    },
    {
      name: "shashinmori-workers",
      cwd: projectRoot,
      script: path.join(projectRoot, "dist", "workers.js"),
      env_file: path.join(projectRoot, ".env"),
      env: {
        START_WORKERS: "true"
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "300M"
    }
  ]
};
