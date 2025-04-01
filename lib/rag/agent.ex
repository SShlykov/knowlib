defmodule Rag.Agent do
  alias Rag.{OpenAIClient, QdrantClient}

  def run_stream(query, on_chunk) do
    with results when is_list(results) <- QdrantClient.search(query) do

      context =
        Enum.map_join(results, "\n\n", & &1["text"])

      messages = [
        %{"role" => "system", "content" => "Ты ассистент, использующий контекст из базы знаний."},
        %{"role" => "user", "content" => "Контекст:\n#{context}"},
        %{"role" => "user", "content" => "Вопрос: #{query}"}
      ]

      OpenAIClient.chat_stream(messages, on_chunk)
    end
  end
end
