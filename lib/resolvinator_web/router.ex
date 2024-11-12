defmodule ResolvinatorWeb.Router do
  use ResolvinatorWeb, :router

  import ResolvinatorWeb.UserAuth
  import ResolvinatorWeb.Plugs.APIProtection

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ResolvinatorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug ResolvinatorWeb.Plugs.SetCurrentUri
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :verify_origin
    plug :rate_limit
  end

  pipeline :api_auth do
    plug ResolvinatorWeb.APIAuthPlug
  end

  scope "/", ResolvinatorWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

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
    post "/users/register", UserRegistrationController, :create
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
      live "/handsigns/new", HandsLive, :new
      live "/handsigns/:id/edit", HandsLive, :edit
      live "/handsigns/:id", HandsLive, :show
      live "/handsigns/:id/show/edit", HandsLive, :edit

      live "/actors", ActorLive.Index, :index
      live "/actors/new", ActorLive.Index, :new
      live "/actors/:id/edit", ActorLive.Index, :edit
      live "/actors/:id", ActorLive.Show, :show
      live "/actors/:id/show/edit", ActorLive.Show, :edit
      live "/categories", CategoryLive.Index, :index
      live "/categories/new", CategoryLive.Index, :new
      live "/categories/:id/edit", CategoryLive.Index, :edit
      live "/categories/:id", CategoryLive.Show, :show
      live "/categories/:id/show/edit", CategoryLive.Show, :edit
      # Risk Management Routes
      live "/risks", RiskLive.Index, :index
      live "/risks/new", RiskLive.Index, :new
      live "/risks/:id/edit", RiskLive.Index, :edit
      live "/risks/:id", RiskLive.Show, :show
      live "/risks/:id/show/edit", RiskLive.Show, :edit

      # Impact Routes
      live "/impacts", ImpactLive.Index, :index
      live "/impacts/new", ImpactLive.Index, :new
      live "/impacts/:id/edit", ImpactLive.Index, :edit
      live "/impacts/:id", ImpactLive.Show, :show
      live "/impacts/:id/show/edit", ImpactLive.Show, :edit

      # Mitigation Routes
      live "/mitigations", MitigationLive.Index, :index
      live "/mitigations/new", MitigationLive.Index, :new
      live "/mitigations/:id/edit", MitigationLive.Index, :edit
      live "/mitigations/:id", MitigationLive.Show, :show
      live "/mitigations/:id/show/edit", MitigationLive.Show, :edit

      # Mitigation Task Routes
      live "/mitigation_tasks", MitigationTaskLive.Index, :index
      live "/mitigation_tasks/new", MitigationTaskLive.Index, :new
      live "/mitigation_tasks/:id/edit", MitigationTaskLive.Index, :edit
      live "/mitigation_tasks/:id", MitigationTaskLive.Show, :show
      live "/mitigation_tasks/:id/show/edit", MitigationTaskLive.Show, :edit

      # Message Routes (if not already present)
      live "/messages", MessageLive.Index, :index
      live "/messages/new", MessageLive.Index, :new
      live "/messages/:id/edit", MessageLive.Index, :edit
      live "/messages/:id", MessageLive.Show, :show
      live "/messages/:id/show/edit", MessageLive.Show, :edit

      live "/resources", ResourceLive.Index, :index
      live "/resources/new", ResourceLive.Index, :new
      live "/resources/:id/edit", ResourceLive.Index, :edit
      live "/resources/:id", ResourceLive.Show, :show
      live "/resources/:id/show/edit", ResourceLive.Show, :edit

      live "/requirements", RequirementLive.Index, :index
      live "/requirements/new", RequirementLive.Index, :new
      live "/requirements/:id/edit", RequirementLive.Index, :edit
      live "/requirements/:id", RequirementLive.Show, :show
      live "/requirements/:id/show/edit", RequirementLive.Show, :edit

      live "/suppliers", SupplierLive.Index, :index
      live "/suppliers/new", SupplierLive.Index, :new
      live "/suppliers/:id/edit", SupplierLive.Index, :edit
      live "/suppliers/:id", SupplierLive.Show, :show
      live "/suppliers/:id/show/edit", SupplierLive.Show, :edit

      live "/documents", DocumentLive.Index, :index
      live "/documents/new", DocumentLive.Index, :new
      live "/documents/:id/edit", DocumentLive.Index, :edit
      live "/documents/:id", DocumentLive.Show, :show
      live "/documents/:id/show/edit", DocumentLive.Show, :edit

      live "/news/broadcast", NewsLive.Broadcast, :index

      # Organization Routes
      live "/organizations", OrganizationLive.Index, :index
      live "/organizations/new", OrganizationLive.Index, :new
      live "/organizations/:id/edit", OrganizationLive.Index, :edit
      live "/organizations/:id", OrganizationLive.Show, :show
      live "/organizations/:id/show/edit", OrganizationLive.Show, :edit

      # Contact Routes
      live "/contacts", ContactLive.Index, :index
      live "/contacts/new", ContactLive.Index, :new
      live "/contacts/:id/edit", ContactLive.Index, :edit
      live "/contacts/:id", ContactLive.Show, :show
      live "/contacts/:id/show/edit", ContactLive.Show, :edit

      # Team Routes
      live "/teams", TeamLive.Index, :index
      live "/teams/new", TeamLive.Index, :new
      live "/teams/:id/edit", TeamLive.Index, :edit
      live "/teams/:id", TeamLive.Show, :show
      live "/teams/:id/show/edit", TeamLive.Show, :edit

      # Q&A Routes
      live "/questions", QuestionLive.Index, :index
      live "/questions/new", QuestionLive.Index, :new
      live "/questions/:id/edit", QuestionLive.Index, :edit
      live "/questions/:id", QuestionLive.Show, :show
      live "/questions/:id/show/edit", QuestionLive.Show, :edit

      live "/answers", AnswerLive.Index, :index
      live "/answers/new", AnswerLive.Index, :new
      live "/answers/:id/edit", AnswerLive.Index, :edit
      live "/answers/:id", AnswerLive.Show, :show
      live "/answers/:id/show/edit", AnswerLive.Show, :edit

      # Project Routes
      live "/projects", ProjectLive.Index, :index
      live "/projects/new", ProjectLive.Index, :new
      live "/projects/:id/edit", ProjectLive.Index, :edit
      live "/projects/:id", ProjectLive.Show, :show
      live "/projects/:id/show/edit", ProjectLive.Show, :edit
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

  # API routes
  scope "/api/v1", ResolvinatorWeb.API do
    pipe_through :api

    # Unauthenticated routes
    scope "/auth" do
      post "/login", SessionController, :create
      post "/refresh", SessionController, :refresh
    end

    # Protected routes
    scope "/" do
      pipe_through :api_auth

      delete "/auth/logout", SessionController, :delete
      resources "/suppliers", SupplierController do
        resources "/contacts", SupplierContactController
        resources "/catalogs", SupplierCatalogController

        get "/performance", SupplierController, :get_performance, as: :performance
        get "/pricing", SupplierController, :get_pricing, as: :pricing
      end
      resources "/projects", ProjectController do
        resources "/actors", ActorController
        resources "/risks", RiskController do
          resources "/impacts", ImpactController
          resources "/mitigations", MitigationController do
            resources "/tasks", MitigationTaskController
            resources "/requirements", RequirementController
            resources "/allocations", AllocationController
          end
        end

        # Inventory management routes
        resources "/inventory", InventoryController do
          # If you don't have a separate InventorySourceController, handle these actions in InventoryController
          get "/sources/:id/availability", InventoryController, :check_availability, as: :availability
          get "/sources/:id/pricing", InventoryController, :get_pricing, as: :pricing
          post "/sources/:id/order", InventoryController, :create_order, as: :order

          get "/analysis", InventoryController, :analyze_item, as: :analysis
          get "/trends", InventoryController, :get_trends, as: :trends
          post "/adjust", InventoryController, :adjust_stock, as: :adjust
          get "/sources", InventoryController, :list_sources, as: :sources
          post "/compare_sources", InventoryController, :compare_sources, as: :compare_sources
        end

        get "/alerts", InventoryController, :get_alerts, as: :alerts
        get "/reports", InventoryController, :generate_report, as: :reports
      end
    end
  end

  scope "/api", ResolvinatorWeb do
    pipe_through :api

    get "/content/:id", ContentController, :show
  end

  # Authenticated routes
  scope "/", ResolvinatorWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Add your protected routes here
    resources "/content", ContentController, only: [:create, :edit, :update, :delete]
  end

  # Public routes with potential content protection
  scope "/", ResolvinatorWeb do
    pipe_through :browser

    resources "/content", ContentController, only: [:index, :show]
  end

  
end
