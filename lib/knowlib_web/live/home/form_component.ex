defmodule KnowlibWeb.Live.Block.FormComponent do
  use KnowlibWeb, :live_component

  alias Knowlib.Knowledge

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage block records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="block-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:icon]} type="text" label="Icon" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Block</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{block: block} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Knowledge.change_block(block))
     end)}
  end

  @impl true
  def handle_event("validate", %{"block" => block_params}, socket) do
    changeset = Knowledge.change_block(socket.assigns.block, block_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"block" => block_params}, socket) do
    block_params =
      block_params
      |> Map.put("user_id", socket.assigns.current_user.id)

    save_block(socket, socket.assigns.action, block_params)
  end

  defp save_block(socket, :edit, block_params) do
    case Knowledge.update_block(socket.assigns.block, block_params) do
      {:ok, block} ->
        {:noreply,
         socket
         |> put_flash(:info, "Block updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_block(socket, :new, block_params) do
    case Knowledge.create_block(block_params) do
      {:ok, block} ->
        {:noreply,
         socket
         |> put_flash(:info, "Блок создан успешно")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
