defmodule IKno.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      IKnoWeb.Telemetry,
      # Start the Ecto repository
      IKno.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: IKno.PubSub},
      # Start Finch
      {Finch, name: IKno.Finch},
      # Start the Endpoint (http/https)
      IKnoWeb.Endpoint
      # Start a worker by calling: IKno.Worker.start_link(arg)
      # {IKno.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IKno.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IKnoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
