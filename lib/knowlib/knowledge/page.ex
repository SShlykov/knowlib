defmodule Knowlib.Knowledge.Page do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pages" do
    field :title, :string
    field :text, :string
    field :order, :integer

    timestamps(type: :utc_datetime)

    belongs_to(:block, Knowlib.Knowledge.Block)
    belongs_to(:user, Knowlib.Accounts.User)
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:text, :title, :order, :user_id, :block_id])
    |> validate_required([:text, :title, :order, :user_id, :block_id])
  end
end
