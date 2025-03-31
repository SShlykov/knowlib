defmodule KnowlibWeb.PageLive.Index do
  use KnowlibWeb, :live_view

  alias Knowlib.Knowledge
  alias Knowlib.Knowledge.Page

  @impl true
  def mount(_params, session, socket) do
    user = Knowlib.Accounts.get_user_by_session_token(session["user_token"])

    socket =
      socket
      |> assign(:current_user, user)
      |> stream(:pages, Knowledge.list_pages(user_id: user.id))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Page")
    |> assign(:page, Knowledge.get_page!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Page")
    |> assign(:page, %Page{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pages")
    |> assign(:page, nil)
  end

  @impl true
  def handle_info({KnowlibWeb.PageLive.FormComponent, {:saved, page}}, socket) do
    {:noreply, stream_insert(socket, :pages, page)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    page = Knowledge.get_page!(id)
    {:ok, _} = Knowledge.delete_page(page)

    {:noreply, stream_delete(socket, :pages, page)}
  end
end
