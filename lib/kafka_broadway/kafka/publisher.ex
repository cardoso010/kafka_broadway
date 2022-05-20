defmodule KafkaBroadway.Kafka.Publisher do
  @moduledoc false
  require Logger

  def publish(message, topic, key \\ :undefined) when is_map(message) do
    config = get_config()
    json_message = Jason.encode!(message)

    :brod.produce_sync_offset(
      config[:brod_producer],
      topic,
      &random_partitioner/4,
      key,
      json_message
    )
  catch
    _type, error ->
      Logger.error("""
      Error while publishing to Kafka.
      Reason: #{inspect(error)}
      Stacktrace: #{__STACKTRACE__}
      """)

      {:error, error}
  end

  defp random_partitioner(_topic, partitions_count, _key, _value) do
    {:ok, Enum.random(0..(partitions_count - 1))}
  end

  defp get_config do
    Application.get_env(:kafka_broadway, KafkaBroadway.Application)
  end
end
