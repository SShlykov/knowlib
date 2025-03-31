defmodule Knowlib.Knowledge.Block do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "blocks" do
    field :name, :string
    field :description, :string
    field :icon, :string

    timestamps(type: :utc_datetime)

    has_many(:pages, Knowlib.Knowledge.Page)

    belongs_to(:user, Knowlib.Accounts.User)
  end

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, [:name, :description, :icon, :user_id])
    |> validate_required([:name, :description, :icon, :user_id])
  end
end
