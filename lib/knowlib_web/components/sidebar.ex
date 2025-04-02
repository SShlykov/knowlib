defmodule KnowlibWeb.Sidebar do
  use Phoenix.Component
  use KnowlibWeb, :verified_routes

  import KnowlibWeb.CoreComponents, only: [modal: 1, input: 1, icon: 1]
  alias Phoenix.LiveView.JS

  def sidebar(assigns) do
    ~H"""
    <div class="fixed flex flex-col justify-between left-0 top-[50px] bg-white border-r border-gray-300 h-[calc(100vh-50px)] w-[250px]">
      <div class="px-4 py-2">
        <form phx-change="search_block">
          <.input
            type="text"
            placeholder="найти"
            name="search"
            value=""
            class="w-full px-2 py-1 border border-gray-300 rounded"
          />
        </form>
      </div>

      <div class="p-4">
        <a
          href={~p"/home"}
          type="button"
          class="w-full flex justify-center text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 mb-2"
        >
          Новый чат
        </a>
      </div>

      <div class="overflow-auto flex-1">
        <div :for={{_block_id, b} <- @blocks} class="border-b border-gray-200">
          <div
            class="flex items-center justify-between px-4 py-3 cursor-pointer hover:bg-gray-50"
            phx-click={JS.toggle_class("hidden", to: "#pages-for-block-#{b.id}")}
          >
            <div class="flex flex-grow justify-between items-center pr-3">
              <div class="font-semibold text-gray-700">
                {b.name}
              </div>
              <.icon name="hero-eye-solid" class="h-3 translate-y-[1px] w-3 text-gray-500" />
            </div>
            <div class="flex space-x-3">
              <.link
                patch={~p"/home/blocks/#{b.id}/edit"}
                class="text-blue-600 hover:text-blue-800 text-sm"
                phx-stop-propagation
              >
                <.icon name="hero-pencil-solid" class="h-3 w-3" />
              </.link>
              <div
                phx-click={JS.push("delete_block", value: %{id: b.id})}
                data-confirm="Точно удалить блок?"
                class="text-red-600 hover:text-red-800 text-sm"
                phx-stop-propagation
              >
                <.icon name="hero-trash-solid" class="h-3 w-3" />
              </div>
            </div>
          </div>

          <ul id={"pages-for-block-#{b.id}"} class="hidden bg-gray-50 text-sm pl-4">
            <li
              :for={page <- b.pages}
              class="flex items-center justify-between px-4 py-2 border-t border-gray-200"
            >
              <.link href={~p"/home/chat/#{page.id}"} class="text-gray-800 hover:underline">
                {page.title}
              </.link>
              <div class="flex space-x-3">
                <.link
                  patch={~p"/home/pages/#{page.id}/edit"}
                  class="text-blue-600 hover:text-blue-800 text-sm"
                  phx-stop-propagation
                >
                  <.icon name="hero-pencil-solid" class="h-3 w-3" />
                </.link>
                <div
                  phx-click={JS.push("delete_page", value: %{id: page.id})}
                  data-confirm="Точно удалить страницу?"
                  class="text-red-600 hover:text-red-800 text-sm"
                  phx-stop-propagation
                >
                  <.icon name="hero-trash-solid" class="h-3 w-3" />
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>

      <div class="flex justify-center p-4">
        <a
          href={~p"/home/blocks/new"}
          class="rounded-full border border-gray-700 py-2 px-8 hover:bg-gray-300 hover:text-zinc-700"
        >
          записать
        </a>

        <.modal
          :if={@live_action in [:new, :edit]}
          id="block-modal"
          show
          on_cancel={JS.patch(~p"/home")}
        >
          <.live_component
            module={KnowlibWeb.Live.Block.FormComponent}
            id={@block.id || :new}
            title={@page_title}
            action={@live_action}
            block={@block}
            patch={~p"/home"}
            current_user={@current_user}
          />
        </.modal>
      </div>
    </div>
    """
  end
end
