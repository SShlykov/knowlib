defmodule KnowlibWeb.Components.ChatBuble do
  use Phoenix.Component
  use KnowlibWeb, :verified_routes

  alias Phoenix.LiveView.JS

  # Главная «обертка» для сообщения (аватар, блок сообщения и меню)
  def chat_bubble(assigns) do
    ~H"""
    <div class={"flex items-start gap-2.5 #{if(@align == "right", do: "flex-row-reverse", else: "")}"}>
      <.avatar icon={@icon} />
      <.chat_message_box align={@align} name={@name} time={@time} text={@text} />
      <.dropdown_menu text={@text} id={@id} align={@align} />
    </div>
    """
  end

  # Аватарка
  def avatar(assigns) do
    ~H"""
    <img class="w-8 h-8 rounded-full" src={@icon} alt="avatar" />
    """
  end

  # Внутренний блок сообщения: имя, дата, текст
  def chat_message_box(assigns) do
    ~H"""
    <div class={
      "border border-gray-200 flex flex-col w-full max-w-[420px] leading-1.5 p-4 bg-gray-100 " <>
      "#{if @align == "right", do: "rounded-tl-xl rounded-bl-xl rounded-br-xl", else: "rounded-e-xl rounded-es-xl"}"
    }>
      <div class="flex items-center space-x-2 rtl:space-x-reverse">
        <span class="text-sm font-semibold text-gray-900">{@name}</span>
        <span class="text-sm font-normal text-gray-500">{@time}</span>
      </div>
      <p class="text-sm font-normal py-2.5 text-gray-900">{@text}</p>
    </div>
    """
  end

  # Кнопка и выпадающее меню
  def dropdown_menu(assigns) do
    ~H"""
    <div
      class={
      "inline-flex self-center items-center gap-4 " <>
      "#{if @align == "right", do: "flex-row-reverse", else: ""}"
    }
      phx-click-away={JS.add_class("hidden", to: "#dropdownDots_#{@id}")}
    >
      <button
        phx-click={JS.remove_class("hidden", to: "#dropdownDots_#{@id}")}
        data-dropdown-toggle="dropdownDots"
        data-dropdown-placement="bottom-start"
        class="border border-gray-100 inline-flex items-start p-2 text-sm font-medium
               text-center text-gray-900 bg-white rounded-lg hover:bg-gray-100
               focus:ring-4 focus:outline-none focus:ring-gray-50"
        type="button"
      >
        <svg
          class="w-4 h-4 text-gray-500"
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          fill="currentColor"
          viewBox="0 0 4 15"
        >
          <path d="M3.5 1.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Z
                   m0 6.041a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Z
                   m0 5.959a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Z" />
        </svg>
      </button>
      <div
        id={"dropdownDots_#{@id}"}
        class="dropdownDots w-[150px] z-10 hidden bg-white
               divide-y divide-gray-100 rounded-lg shadow-sm w-40"
      >
        <ul class="py-2 text-sm text-gray-700 w-full" aria-labelledby="dropdownMenuIconButton">
          <li class="w-full">
            <button
              phx-click="save_page_modal"
              phx-value-text={@text}
              class="align-left w-full block px-4 py-2 hover:bg-gray-100"
            >
              Создать страницу
            </button>
          </li>
          <li class="w-full">
            <button
              phx-click="delete_message"
              phx-value-id={@id}
              class="align-left w-full block px-4 py-2 hover:bg-gray-100"
            >
              Удалить
            </button>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
