defmodule KnowlibWeb.BlockLive.Index do
  use KnowlibWeb, :live_view

  alias Knowlib.Knowledge

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

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Список блоков")
    |> assign(:block, nil)
  end

  defp update_user(socket) do
    user = Knowlib.Accounts.get_user!(socket.assigns.current_user.id)

    assign(socket, current_user: user)
  end
end
