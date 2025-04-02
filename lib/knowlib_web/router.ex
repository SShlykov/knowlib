defmodule KnowlibWeb.Router do
  use KnowlibWeb, :router

  import KnowlibWeb.Auth.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KnowlibWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KnowlibWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live "/", Live.Page
  end

  scope "/", KnowlibWeb do
    pipe_through [:browser, :require_authenticated_user]

    scope "/home", Live do
      live "/", Home, :index

      live "/chat/:id", Home, :show_chat

      live "/blocks/new", Home, :new
      live "/blocks/:id/edit", Home, :edit

      live "/pages/new", Home, :new_page
      live "/pages/:id/edit", Home, :edit_page
    end

    scope "/blocks" do
      live "/", BlockLive.Index, :index

      live "/:id", BlockLive.Show, :show
    end

    scope "/pages" do
      live "/", PageLive.Index, :index

      live "/:id", PageLive.Show, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", KnowlibWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:knowlib, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KnowlibWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/auth", KnowlibWeb.Auth, as: :auth do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{KnowlibWeb.Auth.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/auth", KnowlibWeb.Auth, as: :auth do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{KnowlibWeb.Auth.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/auth", KnowlibWeb.Auth, as: :auth do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{KnowlibWeb.Auth.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
