defmodule KnowlibWeb.Sidebar do
  use Phoenix.Component
  use KnowlibWeb, :verified_routes

  def sidebar(assigns) do
    ~H"""
    <div class="fixed flex flex-col justify-between left-0 top-[50px] bg-white border-r border-gray-300 h-[calc(100vh-50px)] w-[250px]">
      <div>
        <input class="w-full border-b border-gray-500 text-center py-2 " placeholder="search" />
        <%= for b <- @current_user.blocks do %>
          <div class="w-full border-b border-gray-200 text-center py-2">{b.name}</div>
        <% end %>
      </div>

      <div class="flex justify-center pb-4">
        <button class="rounded-full border border-gray-700 py-2 px-8 hover:bg-gray-300 hover:text-zinc-700">
          записать
        </button>
      </div>
    </div>
    """
  end
end
