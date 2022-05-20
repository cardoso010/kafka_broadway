defmodule KafkaBroadway.Kafka.Consumer do
  use Broadway

  require Logger

  alias Broadway.Message

  @doc false
  def start_link(_) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      context: %{},
      producer: [
        module: {BroadwayKafka.Producer, producer_config_opts()}
      ],
      processors: [
        default: [concurrency: 10]
      ],
      batchers: [
        default: [
          batch_size: 30,
          batch_timeout: 1_000
        ],
        errors: [
          batch_size: 50,
          batch_timeout: 1_000
        ]
      ]
    )
  end

  @impl Broadway
  def prepare_messages(messages, _ctx) do
    # We can prepare the messages here
    messages
  end

  @impl Broadway
  def handle_message(:default, %Message{data: data, metadata: meta} = message, _ctx) do
    Logger.info("Got message from topic #{meta[:topic]}")

    case Jason.decode(data) do
      {:ok, decoded} ->
        Message.update_data(message, fn _ -> decoded end)

      {:error, _} = err ->
        message
        |> Message.failed(err)
        |> Message.put_batcher(:errors)
    end
  end

  @impl Broadway
  def handle_batch(:default, messages, _batch_info, _ctx) do
    Logger.info("Got batch of #{Enum.count(messages)} messages in :default batcher")
    messages
  end

  @impl Broadway
  def handle_batch(:errors, messages, _batch_info, _ctx) do
    Logger.info("Got batch of #{Enum.count(messages)} messages in :errors batcher")

    # The failed messages will be send to handle_failed but here we can do a audit
    messages
  end

  @impl Broadway
  def handle_failed(messages, _ctx) do
    Logger.info("#{Enum.count(messages)} failed messages")

    # Here we can apply strategy to save the messages or DLQ -> Dead Letter Queue
    messages
  end

  defp producer_config_opts do
    [
      hosts: "localhost:9092",
      group_id: "kafka_broadway",
      topics: ["domain_fct_testSent_0"]
    ]
  end
end
