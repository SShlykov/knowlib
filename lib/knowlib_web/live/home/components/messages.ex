defmodule KnowlibWeb.Components.Room do
  use Phoenix.Component
  import KnowlibWeb.Components.ChatBuble

  def list_messages(assigns) do
    ~H"""
    <div class="flex flex-col items-center w-full max-h-[calc(100vh-200px)] gap-6 pt-10 overflow-y-auto" id="messages" phx-update="stream">
      <div :for={{dom_id, message} <- @messages} id={dom_id} class="w-full max-w-[700px]">
        <.chat_buble icon={message.icon} time={message.time} name={message.name} align={message.align} text={message.text} id={message.id}/>
      </div>
    </div>
    """
  end

  def show_messages(assigns) do
    ~H"""
    <div>
      <.list_messages messages={@messages} />
    </div>
    """
  end
end
