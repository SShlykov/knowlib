defmodule KnowlibWeb.Live.Home do
  use KnowlibWeb, :live_view

  import KnowlibWeb.Components.Room
  alias Knowlib.Knowledge
  alias Knowlib.Knowledge.Block

  def mount(_params, session, socket) do
    current_user = Knowlib.Accounts.get_user_by_session_token(session["user_token"])

    socket =
      socket
      |> assign(:current_user, current_user)
      |> stream(:messages, [
        %{icon:  "https://cdn-icons-png.flaticon.com/512/2021/2021646.png",
          time:  now(),
          name:  "system",
          align: "right",
          text:  "Введите свое сообщение",
          id:    rand_string()
        }
      ])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)
      |> stream(:blocks, Knowledge.list_blocks(user_id: socket.assigns.current_user.id))

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
  def handle_event("send_message", %{"message" => client_message}, socket) do
    socket =
      socket
      |> stream_insert(:messages, message(client_message, socket.assigns.current_user.email))

    send(self(), {:send_system_message, "Думаю..."})

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_message", %{"id" => id}, socket) do
    {:noreply, stream_delete(socket, :messages, %{id: id})}
  end

  @impl true
  def handle_info({:send_system_message, system_message}, socket) do
    :timer.sleep(2000)

    socket =
      socket
      |> stream_insert(:messages, message(system_message))

    {:noreply, socket}
  end

  def message(message, name) do
    message("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUW0u5Eiiy3oM6wcpeEE6sXCzlh8G-tX1_Iw&s", "left", message, name)
  end

  def message(message) do
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
