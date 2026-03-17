module.exports = {
  apps: [
    {
      name: "shashinmori-api",
      script: "dist/index.js",
      env_file: ".env",
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
      script: "dist/workers.js",
      env_file: ".env",
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
