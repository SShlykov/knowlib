defmodule Knowlib.Repo do
  use Ecto.Repo,
    otp_app: :knowlib,
    adapter: Ecto.Adapters.Postgres
end
