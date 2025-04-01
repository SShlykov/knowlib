defmodule Knowlib.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KnowlibWeb.Telemetry,
      Knowlib.Repo,
      {DNSCluster, query: Application.get_env(:knowlib, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Knowlib.PubSub},
      {Finch, name: Knowlib.Finch},
      KnowlibWeb.Endpoint,
      {Task, fn -> Rag.QdrantInitializer.init_collection() end}
    ]

    opts = [strategy: :one_for_one, name: Knowlib.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    KnowlibWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
