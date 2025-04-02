defmodule KnowlibWeb.Live.Home do
  require Logger
  use KnowlibWeb, :live_view

  import KnowlibWeb.Components.Room
  alias Knowlib.Knowledge
  alias Knowlib.Knowledge.Block

  def mount(_params, session, socket) do
    current_user = Knowlib.Accounts.get_user_by_session_token(session["user_token"])

    init_message = %{
      icon:  "https://cdn-icons-png.flaticon.com/512/2021/2021646.png",
      time:  now(),
      name:  "system",
      align: "right",
      text:  "Введите свое сообщение",
      id:    rand_string()
    }

    socket =
      socket
      |> assign(:uploading_status, false)
      |> assign(:current_user, current_user)
      |> assign(:last_message, init_message)
      |> stream(:messages, [init_message])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    blocks = Knowledge.list_blocks(user_id: socket.assigns.current_user.id)
    block_knowledge_count =
      blocks
      |> Enum.map(fn %{name: name, pages: pages} -> %{name: name, count: length(pages)} end)
      |> Enum.sort(& &1.count > &2.count)
      |> Enum.take(5)

    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)
      |> assign(:total_blocks, length(blocks))
      |> assign(:block_knowledge_count, block_knowledge_count)
      |> stream(:blocks, blocks)

    {:noreply, socket}
  end

  def handle_event("search_block", %{"search" => search}, socket) do
    all_blocks = Knowledge.list_blocks(user_id: socket.assigns.current_user.id)

    filtred_blocks =
      all_blocks
      |> Enum.filter(fn %{name: name} -> String.contains?(name, search) end)

    socket =
      socket
      |> remove_blocks(all_blocks)
      |> add_blocks(filtred_blocks)

    {:noreply, socket}
  end

  @impl true
  def handle_event("send_message", %{"message" => client_message}, socket) when client_message != "" do
    self = self()

    spawn(fn ->
      Rag.Agent.run_stream("ответь в 100 словах: " <> client_message, fn
        %{"choices" => [%{"delta" => %{"finish_reason" => "stop"}}]} ->
          send(self, :done_upload)
          :ok
        %{"choices" => [%{"delta" => %{"content" => content}}]} when content != "" ->
          send(self, {:send_ai_responce_message, content})
        _any ->
          :ok
      end)
    end)

    message = user_message(client_message, socket.assigns.current_user.email)

    socket =
      socket
      |> assign(:uploading_status, true)
      |> assign(:last_message, message)
      |> stream_insert(:messages, message)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_message", %{"id" => id}, socket) do
    {:noreply, stream_delete(socket, :messages, %{id: id})}
  end

  @impl true
  def handle_info({:send_ai_responce_message, system_message}, %{assigns: %{last_message: %{name: "system"} = msg}} = socket) do
    new_message = Map.update!(msg, :text, fn text -> text <> system_message end)

    socket =
      socket
      |> stream_delete(:messages, msg)
      |> assign(:last_message, new_message)
      |> stream_insert(:messages, new_message)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:send_ai_responce_message, system_message}, %{assigns: %{last_message: msg}} = socket) do
    message = system_message(system_message)

    socket =
      socket
      |> assign(:last_message, message)
      |> stream_insert(:messages, message)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:done_upload, socket) do
    socket =
      socket
      |> assign(:uploading_status, false)

    {:noreply, socket}
  end

  def user_message(message, name) do
    message("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUW0u5Eiiy3oM6wcpeEE6sXCzlh8G-tX1_Iw&s", "left", message, name)
  end

  def system_message(message) do
    message("https://cdn-icons-png.flaticon.com/512/2021/2021646.png", "right", message, "system")
  end

  def message(icon, align, message, name) do
    %{
      icon:  icon,
      time:  now(),
      name:  name,
      align: align,
      text:  message,
      id:    rand_string()
    }
  end

  def rand_string() do
    :crypto.strong_rand_bytes(12)
    |> Base.url_encode64()
    |> String.replace(~r/[-_=]/, "")
  end

  def now, do: DateTime.utc_now() |> Calendar.strftime("%H:%M")

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Редактировать")
    |> assign(:block, Knowledge.get_block!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Новый блок")
    |> assign(:block, %Block{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Список блоков")
    |> assign(:block, nil)
  end


  defp remove_blocks(socket, blocks) do
    Enum.reduce(blocks, socket, fn block, acc ->
      stream_delete(acc, :blocks, block)
    end)
  end

  defp add_blocks(socket, blocks) do
    Enum.reduce(blocks, socket, fn block, acc ->
      stream_insert(acc, :blocks, block)
    end)
  end
end
