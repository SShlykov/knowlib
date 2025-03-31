defmodule KnowlibWeb.MenuContainer do
  use Phoenix.Component
  use KnowlibWeb, :verified_routes

  import KnowlibWeb.Topbar
  import KnowlibWeb.Sidebar

  def menu_container(assigns) do
    ~H"""
    <div>
      <.topbar current_user={@current_user} />
      <.sidebar :if={@current_user} current_user={@current_user} />
      <div :if={@current_user} class="h-[calc(100vh-50px)] overflow-y-auto py-4 bg-gray-50 pt-[50px] pl-[250px]">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
