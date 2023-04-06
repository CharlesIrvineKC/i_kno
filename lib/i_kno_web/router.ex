defmodule IKnoWeb.Router do
  use IKnoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {IKnoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IKnoWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/subjects", SubjectLive.Index, :index
    live "/subjects/new", SubjectLive.Index, :new
    live "/subjects/:id/edit", SubjectLive.Index, :edit

    live "/subjects/:id", SubjectLive.Show, :show
    live "/subjects/:id/show/edit", SubjectLive.Show, :edit

    live "/topics", TopicLive.Index, :index
    live "/topics/new", TopicLive.Index, :new
    live "/topics/:id/edit", TopicLive.Index, :edit

    live "/topics/:id", TopicLive.Show, :show
    live "/topics/:id/show/edit", TopicLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", IKnoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:i_kno, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: IKnoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
