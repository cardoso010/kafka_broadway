defmodule KafkaBroadway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  alias KafkaBroadway.Kafka.Consumer

  @impl true
  def start(_type, _args) do
    config = Application.get_env(:kafka_broadway, __MODULE__)

    children = [
      KafkaBroadwayWeb.Telemetry,
      {Phoenix.PubSub, name: KafkaBroadway.PubSub},
      KafkaBroadwayWeb.Endpoint,
      Supervisor.child_spec(Consumer, id: :kafka_consumer),
      brod_client(config)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KafkaBroadway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KafkaBroadwayWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp brod_client(config) do
    brod_hosts = parse_hosts(config[:kafka_hosts])

    %{
      id: config[:brod_producer],
      start:
        {:brod_client, :start_link,
         [brod_hosts, config[:brod_producer], [auto_start_producers: true]]}
    }
  end

  defp parse_hosts(hosts_single_binary) when is_binary(hosts_single_binary) do
    hosts_single_binary
    |> String.split(",")
    |> Enum.map(fn host_port ->
      [host, port] = String.split(host_port, ":")
      {host, String.to_integer(port)}
    end)
  end
end
