import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kafka_broadway, KafkaBroadwayWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ych39VZIK/JlmNKF6XCXyCV3K5Z+dyAVcxkAqfk398eJhPSbWdwZXmsF/Csb95Q1",
  server: false

# In test we don't send emails.
config :kafka_broadway, KafkaBroadway.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
