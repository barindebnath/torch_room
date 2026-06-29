defmodule TorchRoom.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TorchRoomWeb.Telemetry,
      TorchRoom.Repo,
      {DNSCluster, query: Application.get_env(:torch_room, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TorchRoom.PubSub},
      # Start a worker by calling: TorchRoom.Worker.start_link(arg)
      # {TorchRoom.Worker, arg},
      # Start to serve requests, typically the last entry
      TorchRoomWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TorchRoom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TorchRoomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
