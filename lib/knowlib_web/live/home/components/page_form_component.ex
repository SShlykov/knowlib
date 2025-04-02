defmodule KnowlibWeb.Live.Page.FormComponent do
  use KnowlibWeb, :live_component

  alias Knowlib.Knowledge

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage page records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="page-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:order]} value={0} type="number" label="Очередь" />
        <.input
          field={@form[:block_id]}
          type="select"
          label="Вебери блок знаний"
          options={
            Knowlib.Knowledge.list_blocks(user_id: @current_user.id)
            |> Enum.map(& &1.name)
          }
        />

        <.input field={@form[:title]} type="text" label="Заголовок" />
        <.input field={@form[:text]} type="textarea" label="Текст" />
        <:actions>
          <.button phx-disable-with="Saving...">Сохранить</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{page: page} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Knowledge.change_page(page))
     end)}
  end

  @impl true
  def handle_event("validate", %{"page" => page_params}, socket) do
    changeset = Knowledge.change_page(socket.assigns.page, page_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"page" => page_params}, socket) do
    uid = socket.assigns.current_user.id
    name = page_params["block_id"]

    page_params =
      page_params
      |> Map.update!("block_id", fn name ->
        Knowledge.get_block_by_uid_and_name(uid, name).id
      end)
      |> Map.put("user_id", uid)

    save_page(socket, socket.assigns.action, page_params)
  end

  defp save_page(socket, :edit_page, page_params) do
    case Knowledge.update_page(socket.assigns.page, page_params) do
      {:ok, page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_page(socket, :new_page, page_params) do
    case Knowledge.create_page(page_params) do
      {:ok, page} ->
        Rag.QdrantClient.upsert_text(page.block_id, page.id, page.text)

        {:noreply,
         socket
         |> put_flash(:info, "Page created successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
