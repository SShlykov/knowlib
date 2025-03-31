defmodule KnowlibWeb.Topbar do
  use Phoenix.Component
  use KnowlibWeb, :verified_routes

  def topbar(assigns) do
    ~H"""
    <header class="top-0 left-0 w-full bg-white border-b border-gray-300 px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between border-b border-zinc-100 py-3 text-sm">
        <div class="flex items-center gap-4">
          <a href={~p"/"}>
            <img src={~p"/images/logo.svg"} width="36" />
          </a>
        </div>

        <div class="flex items-center gap-4 font-semibold leading-6 text-zinc-900">
          <%= if @current_user do %>
            <div class="text-[0.8125rem] leading-6 text-zinc-900 hover:text-orange-500 cursor-pointer">
              {@current_user.email}
            </div>
            <div>
              <.link
                href={~p"/auth/users/settings"}
                class="rounded-full border border-gray-700 py-2 px-4 hover:bg-gray-300 hover:text-zinc-700"
              >
                настройки
              </.link>
            </div>
            <div>
              <.link
                href={~p"/auth/users/log_out"}
                method="delete"
                class="rounded-full border border-gray-700 py-2 px-4 hover:bg-gray-300 hover:text-zinc-700"
              >
                выйти
              </.link>
            </div>
          <% else %>
            <.link
              href={~p"/auth/users/register"}
              class="rounded-full border border-gray-700 py-2 px-4 hover:bg-gray-300 hover:text-zinc-700"
            >
              регистрация
            </.link>
            <.link
              href={~p"/auth/users/log_in"}
              class="rounded-full border border-gray-700 py-2 px-4 hover:bg-gray-300 hover:text-zinc-700"
            >
              войти
            </.link>
          <% end %>
        </div>
      </div>
    </header>
    """
  end
end
