defmodule Rag.OpenAIClient do
  @moduledoc """
  Streaming client for OpenAI Chat API using Tesla + Finch + SSE.
  """

  alias Tesla.Env

  @base_url "https://api.openai.com/v1"
  @default_model "gpt-4"

  # Public: Builds a Tesla client with SSE and JSON support
  def client(token \\ System.get_env("OPENAI_API_KEY")) do
    middleware = [
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.BearerAuth, token: token},
      {Tesla.Middleware.JSON, decode_content_types: ["text/event-stream"]},
      {Tesla.Middleware.SSE, only: :data}
    ]

    Tesla.client(middleware, {Tesla.Adapter.Finch, name: Knowlib.Finch})
  end

  def chat_stream(messages, on_chunk \\ &put_chunck/1) do
    chat_stream(client(), messages, on_chunk)
  end

  # Public: Chat completion with streaming support
  def chat_stream(client, messages, on_chunk, opts \\ []) when is_function(on_chunk) do
    model = Keyword.get(opts, :model, @default_model)

    data = %{
      model: model,
      messages: messages,
      stream: true
    }

    {:ok, env} = Tesla.post(client, "/chat/completions", data, opts: [adapter: [response: :stream]])
    |> IO.inspect(label: "stream")

    env.body
    |> Stream.each(& on_chunk.(&1))
    |> Stream.run()
  end

  # Public: Chat completion without stream (standard JSON response)
  def chat(client \\ client(), messages, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)

    data = %{
      model: model,
      messages: messages
    }

    case Tesla.post(client, "/chat/completions", data) do
      {:ok, %Env{body: %{"choices" => [%{"message" => %{"content" => content}}]}}} ->
        {:ok, content}

      {:ok, %Env{body: body}} ->
        {:error, {:unexpected_response, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Public: Embedding for vector search / RAG
  def embed(client \\ client(), text, model \\ "text-embedding-ada-002") do
    data = %{
      input: text,
      model: model
    }

    case Tesla.post(client, "/embeddings", data) do
      {:ok, %Env{body: %{"data" => [%{"embedding" => vector}]}}} ->
        {:ok, vector}

      {:ok, %Env{body: body}} ->
        {:error, {:unexpected_response, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp put_chunck(%{"choices" => [%{"delta" => %{"finish_reason" => "stop"}}]}), do: :ok
  defp put_chunck(%{"choices" => [%{"delta" => %{"content" => content}}]}) when content != "", do: IO.puts(content)
  defp put_chunck(_any), do: :ok
end
