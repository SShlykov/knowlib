defmodule KnowlibWeb.Live.Home do
  use KnowlibWeb, :live_view

  import KnowlibWeb.Components.ChatBuble

  def mount(_params, session, socket) do
    current_user = Knowlib.Accounts.get_user_by_session_token(session["user_token"])

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:messages, [
        %{icon:  "https://cdn-icons-png.flaticon.com/512/2021/2021646.png",
          time:  now(),
          name:  "system",
          align: "right",
          text:  "Введите свое сообщение",
          id:    "1"
        },
        %{
          icon:  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUW0u5Eiiy3oM6wcpeEE6sXCzlh8G-tX1_Iw&s",
          time:  now(),
          name:  current_user.email,
          align: "left",
          text:  "Три брата получили 24 яблока, причём. каждому досталось столько, сколько ему было лет. Младший получил меньше всех, остался недоволен и предложил братьям следующее: «Я оставлю себе только половину своих яблок, а остальные разделю между вами поровну. Затем пусть так поступит средний, а за ним и старший». Братья, не раздумывая, согласились, но прогадали: в результате яблок у всех оказалось поровну. Сколько лет было каждому из братьев?",
          id:     "2"
        }
      ])

    {:ok, socket}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    IO.inspect(message)
    {:noreply, add_message(message, socket)}
  end

  def add_message(client_message, socket) do
    messages = socket.assigns.messages ++ [message(client_message, socket.assigns.current_user.email)]

    assign(socket, :messages, messages)
  end

  def message(message, name) do
    message("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUW0u5Eiiy3oM6wcpeEE6sXCzlh8G-tX1_Iw&s", "left", message, name)
  end

  def message(message) do
    message("https://cdn-icons-png.flaticon.com/512/2021/2021646.png", "right", message, "system")
  end

  def message(icon, align, message, name) do
    %{
      icon:  icon,
      time:  now(),
      name:  name,
      align: align,
      text:  message,
      id:    rand_string()
    }
  end

  def rand_string() do
    :crypto.strong_rand_bytes(12)
    |> Base.url_encode64()
    |> String.replace(~r/[-_=]/, "")
  end

  def now, do: DateTime.utc_now() |> Calendar.strftime("%H:%M")
end
