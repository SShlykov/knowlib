defmodule KnowlibWeb.Sidebar do
  use Phoenix.Component
  use KnowlibWeb, :verified_routes

  import KnowlibWeb.CoreComponents, only: [modal: 1, input: 1]
  alias Phoenix.LiveView.JS

  def sidebar(assigns) do
    ~H"""
    <div class="fixed flex flex-col justify-between left-0 top-[50px] bg-white border-r border-gray-300 h-[calc(100vh-50px)] w-[250px]">
      <div>
        <form phx-change="search_block" class="px-4">
          <.input type="text" placeholder="найти" name="search" value="" />
        </form>
        <div
          :for={{_block_id, b} <- @blocks} class="w-full border-b border-gray-200 text-center py-2">
          <div class="py-4">{b.name} <a class="text-xs text-gray-700" href={~p"/home/blocks/#{b.id}/edit"}>ред. </a></div>
          <ul>
            <li :for={page <- b.pages} >{page.title}</li>
          </ul>
        </div>
      </div>

      <div class="flex justify-center pb-4">
        <a href={~p"/home/blocks/new"} class="rounded-full border border-gray-700 py-2 px-8 hover:bg-gray-300 hover:text-zinc-700">
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
