defmodule KnowlibWeb.Live.Home do
  use KnowlibWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:current_user, Knowlib.Accounts.get_user_by_session_token(session["user_token"]))

    {:ok, socket}
  end
end
