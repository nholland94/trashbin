use Mix.Config

config :zeus, port: 3010

config :zeus, :service_domains, [
  peak: "localhost:3000",
  boards: "localhost:4000"
]

config :logger, :console,
  format: "$date $time [$level] $message\n"
