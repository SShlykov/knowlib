defmodule Rag.QdrantClient do
  require Logger
  use Tesla

  @collection "documents"
  @vector_size 1536
  @distance "Cosine"

  plug Tesla.Middleware.BaseUrl, "http://localhost:6333"
  plug Tesla.Middleware.JSON

  alias Rag.OpenAIClient

  def upsert_text(block_id, text_id, text) do
    id = Ecto.UUID.generate()

    with {:ok, vector} <- OpenAIClient.embed(text) do
      payload = %{
        block_id: block_id,
        text_id: text_id,
        text: text
      }

      body = %{
        points: [
          %{
            id: id,
            vector: vector,
            payload: payload
          }
        ]
      }

      Logger.info("Posting point #{id} with embedding size #{length(vector)}")

      case put("/collections/#{@collection}/points", body) do
        {:ok, %Tesla.Env{status: 200}} = ok ->
          Logger.info("Inserted point #{id}")
          ok

        {:ok, %Tesla.Env{status: code, body: body}} ->
          Logger.error("Insert failed: status=#{code}, body=#{inspect(body)}")
          {:error, body}

        {:error, reason} ->
          Logger.error("Insert error: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  def delete_point(block_id, text_id) do
    point_id = "#{block_id}_#{text_id}"

    post("/collections/#{@collection}/points/delete", %{
      points: [point_id]
    })
  end

  def delete_block(block_id) do
    post("/collections/#{@collection}/points/delete", %{
      filter: %{
        must: [
          %{key: "block_id", match: %{"value" => block_id}}
        ]
      }
    })
  end

  def upsert_block(block_id, texts) do
    texts
    |> Enum.map(fn {text_id, text} ->
      Logger.info("Inserting #{block_id}:#{text_id}")

      case upsert_text(block_id, text_id, text) do
        {:ok, _} -> :ok
        any ->
          Logger.error("Some inserts failed: #{inspect(any)}")
          {:error, any}
      end
    end)
  end

  def search(query, limit \\ 5) do
    with {:ok, vector} <- OpenAIClient.embed(query),
         {:ok, %Tesla.Env{body: %{"result" => results}}} <- search_vector(vector, limit) do

      results
      |> Enum.map( fn %{"payload" => payload, "score" => score} ->
        %{text: payload["text"], block_id: payload["block_id"], score: score}
      end)
    end
  end

  def list_points(limit \\ 10) do
    post("/collections/#{@collection}/points/scroll", %{
      limit: limit,
      with_payload: true
    })
  end

  def collection do
    @collection
  end

  def ensure_collection() do
    case get("/collections/#{@collection}") do
      {:ok, %Tesla.Env{status: 200}} ->
        :ok

      {:ok, %Tesla.Env{status: 404}} ->
        case create_collection() do
          {:ok, _any} -> :ok
          any -> any
        end

      {:error, reason} ->
        IO.warn("Could not check collection: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp search_vector(vector, limit) do
    post("/collections/#{@collection}/points/search", %{
      vector: vector,
      limit: limit,
      with_payload: true
    })
  end

  defp create_collection() do
    body = %{
      vectors: %{
        size: @vector_size,
        distance: @distance,
        type: "DenseVector"
      }
    }

    case put("/collections/#{@collection}", body) do
      {:ok, %Tesla.Env{status: 200}} ->
        Logger.info("Qdrant collection '#{@collection}' created.")

      {:ok, %Tesla.Env{status: code}} ->
        Logger.error("Unexpected status while creating collection: #{code}")

      {:error, reason} ->
        Logger.error("Failed to create Qdrant collection: #{inspect(reason)}")
    end
  end
end
