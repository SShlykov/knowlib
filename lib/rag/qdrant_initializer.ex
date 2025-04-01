defmodule Rag.QdrantInitializer do
  require Logger

  alias Rag.QdrantClient

  def init_collection do
    case QdrantClient.ensure_collection() do
      :ok ->
        Logger.info("Qdrant collection '#{QdrantClient.collection()}' is ready.")
        {:stop, :normal}

      {:error, reason} ->
        Logger.error("Failed to initialize Qdrant collection: #{inspect(reason)}")
        {:stop, reason}
    end
  end
end
