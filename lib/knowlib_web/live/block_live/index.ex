defmodule KnowlibWeb.BlockLive.Index do
  use KnowlibWeb, :live_view

  alias Knowlib.Knowledge
  alias Knowlib.Knowledge.Block

  @impl true
  def mount(_params, session, socket) do
    user = Knowlib.Accounts.get_user_by_session_token(session["user_token"])

    socket =
      socket
      |> assign(:current_user, user)
      |> stream(:blocks, Knowledge.list_blocks(user_id: user.id))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

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

  @impl true
  def handle_info({KnowlibWeb.BlockLive.FormComponent, {:saved, block}}, socket) do
    {:noreply, stream_insert(socket, :blocks, block)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    block = Knowledge.get_block!(id)
    {:ok, _} = Knowledge.delete_block(block)

    {:noreply, stream_delete(socket, :blocks, block)}
  end
end
