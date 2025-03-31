defmodule Knowlib.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :text
      add :title, :text
      add :order, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :block_id, references(:blocks, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:pages, [:user_id])
    create index(:pages, [:block_id])
  end
end
