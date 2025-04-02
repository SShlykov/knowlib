defmodule Rag.Agent do
  alias Rag.{OpenAIClient, QdrantClient}

  def run_stream(query, on_chunk) do
    with results when is_list(results) <- QdrantClient.search(query) do
      role = """
      Ты ассистент, использующий контекст из базы знаний. Твоя главная задача максимально емко отвечать на заданные вопросы
      """

      context = """
      Контекст:
      #{Enum.map_join(results, "\n\n", & &1[:text])}
      """

      task = """
      Задача: ты должен мыслить последовательно:
      1. Проанализировать как исходный текст связан с контекстом
      2. Выделить основные тезисы
      3. Емко сформулировать ответ исходя из стиля написанного контекста
      4. НЕ объяснять свой выбор и действия или результаты анализа
      """

      limits = """
      Ограничения:
      1. Ответ не должен быть более 200 слов
      """

      rules = """
      #{role}
      #{context}
      #{task}
      #{limits}
      """

      messages = [
        %{"role" => "user", "content" => rules},
        %{"role" => "user", "content" => "Вопрос: #{query}"}
      ]

      OpenAIClient.chat_stream(messages, on_chunk)
    end
  end
end
