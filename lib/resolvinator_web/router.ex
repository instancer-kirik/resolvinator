defmodule ResolvinatorWeb.Router do
  use ResolvinatorWeb, :router

  import ResolvinatorWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ResolvinatorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    # plug :fetch_github_user # <-- add this

  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :protect_from_forgery
    plug ResolvinatorWeb.APIAuthPlug
    plug :put_secure_browser_headers
  end

  scope "/", ResolvinatorWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", ResolvinatorWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:resolvinator, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ResolvinatorWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes
  scope "/auth/github", ResolvinatorWeb do
    pipe_through [:browser]
    get "/", GithubAuthController, :request
    get "/callback", GithubAuthController, :callback
  end
  scope "/", ResolvinatorWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ResolvinatorWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ResolvinatorWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ResolvinatorWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/advantages", AdvantageLive.Index, :index
      live "/advantages/new", AdvantageLive.Index, :new
      live "/advantages/:id/edit", AdvantageLive.Index, :edit

      live "/advantages/:id", AdvantageLive.Show, :show
      live "/advantages/:id/show/edit", AdvantageLive.Show, :edit


      live "/problems", ProblemLive.Index, :index
      live "/problems/new", ProblemLive.Index, :new
      live "/problems/:id/edit", ProblemLive.Index, :edit

      live "/problems/:id", ProblemLive.Show, :show
      live "/problems/:id/show/edit", ProblemLive.Show, :edit


      live "/solutions", SolutionLive.Index, :index
      live "/solutions/new", SolutionLive.Index, :new
      live "/solutions/:id/edit", SolutionLive.Index, :edit

      live "/solutions/:id", SolutionLive.Show, :show
      live "/solutions/:id/show/edit", SolutionLive.Show, :edit

      live "/lessons", LessonLive.Index, :index
      live "/lessons/new", LessonLive.Index, :new
      live "/lessons/:id/edit", LessonLive.Index, :edit

      live "/lessons/:id", LessonLive.Show, :show
      live "/lessons/:id/show/edit", LessonLive.Show, :edit
      live "/handsigns", HandsLive, :index
    end
  end

  scope "/", ResolvinatorWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ResolvinatorWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/api", ResolvinatorWeb do
    pipe_through :api

    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
    
    # Protected routes
    scope "/" do
      pipe_through :api_auth

      resources "/projects", ProjectController do
        resources "/risks", RiskController do
          resources "/impacts", ImpactController
          resources "/mitigations", MitigationController do
            resources "/tasks", MitigationTaskController
          end
        end
        resources "/actors", ActorController
        resources "/risk_categories", RiskCategoryController
      end
    end
  end
end
