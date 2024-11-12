defmodule ResolvinatorWeb.Components.NavigationComponents do
  use Phoenix.Component
  import ResolvinatorWeb.CoreComponents
  import Phoenix.LiveView.Helpers
  alias Phoenix.LiveView.JS

  # Main navigation menu
  attr :current_user, :any, required: true
  attr :current_uri, :string, required: true
  attr :show_secondary_nav, :boolean, default: true

  def nav_menu(assigns) do
    ~H"""
    <nav class="bg-white shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <.link patch="/" class="text-xl font-bold text-gray-800">
                Resolvinator
              </.link>
            </div>
            
            <%!-- Desktop Navigation --%>
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <%= if @current_user do %>
                <%!-- Content Dropdown --%>
                <div class="relative" x-data="{ open: false }" @mouseleave="open = false">
                  <button 
                    class={[
                      "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium",
                      if(String.contains?(current_path(assigns), ["/problems", "/solutions", "/lessons", "/advantages", "/theorems", "/topics", "/questions"])) do
                        "border-blue-500 text-gray-900"
                      else
                        "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
                      end
                    ]}
                    @mouseenter="open = true"
                    @click="open = !open"
                  >
                    Content
                    <svg class="ml-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                      <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                    </svg>
                  </button>
                  <div 
                    x-show="open"
                    x-transition
                    class="absolute left-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5"
                    role="menu"
                  >
                    <div class="py-1" role="none">
                      <.nav_dropdown_link patch="/problems">Problems</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/solutions">Solutions</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/lessons">Lessons</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/advantages">Advantages</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/theorems">Theorems</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/topics">Topics</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/qa">Q&A</.nav_dropdown_link>
                    </div>
                  </div>
                </div>

                <%!-- Management Dropdown --%>
                <div class="relative" x-data="{ open: false }" @mouseleave="open = false">
                  <button 
                    class={[
                      "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium",
                      if(String.contains?(current_path(assigns), ["/risks", "/impacts", "/mitigations", "/projects", "/requirements", "/resources", "/documents"])) do
                        "border-blue-500 text-gray-900"
                      else
                        "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
                      end
                    ]}
                    @mouseenter="open = true"
                    @click="open = !open"
                  >
                    Management
                    <svg class="ml-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                      <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                    </svg>
                  </button>
                  <div 
                    x-show="open"
                    x-transition
                    class="absolute left-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5"
                    role="menu"
                  >
                    <div class="py-1" role="none">
                      <div class="px-3 py-1 text-xs font-semibold text-gray-500 uppercase tracking-wider">Risk Management</div>
                      <.nav_dropdown_link patch="/risks">Risks</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/impacts">Impacts</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/mitigations">Mitigations</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/categories">Categories</.nav_dropdown_link>
                      
                      <div class="border-t border-gray-100 my-1"></div>
                      
                      <div class="px-3 py-1 text-xs font-semibold text-gray-500 uppercase tracking-wider">Project Management</div>
                      <.nav_dropdown_link patch="/projects">Projects</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/requirements">Requirements</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/resources">Resources</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/documents">Documents</.nav_dropdown_link>
                    </div>
                  </div>
                </div>

                <%!-- Tools Dropdown --%>
                <div class="relative" x-data="{ open: false }" @mouseleave="open = false">
                  <button 
                    class={[
                      "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium",
                      if(String.contains?(current_path(assigns), ["/suppliers", "/actors", "/inventory", "/rewards", "/assistant"])) do
                        "border-blue-500 text-gray-900"
                      else
                        "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
                      end
                    ]}
                    @mouseenter="open = true"
                    @click="open = !open"
                  >
                    Tools
                    <svg class="ml-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                      <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                    </svg>
                  </button>
                  <div 
                    x-show="open"
                    x-transition
                    class="absolute left-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5"
                    role="menu"
                  >
                    <div class="py-1" role="none">
                      <.nav_dropdown_link patch="/suppliers">Suppliers</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/inventory">Inventory</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/actors">Actors</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/rewards">Rewards</.nav_dropdown_link>
                      <.nav_dropdown_link patch="/assistant">AI Assistant</.nav_dropdown_link>
                    </div>
                  </div>
                </div>

                <%!-- Direct Links --%>
                <.nav_link patch="/events" active={current_path(assigns) =~ "/events"}>Events</.nav_link>
                <.nav_link patch="/messages" active={current_path(assigns) =~ "/messages"}>Messages</.nav_link>

                <%= if @current_user.is_admin do %>
                  <.nav_link patch="/analytics" active={current_path(assigns) =~ "/analytics"}>Analytics</.nav_link>
                <% end %>
              <% end %>
            </div>
          </div>

          <%!-- User Menu --%>
          <div class="flex items-center">
            <%= if @current_user do %>
              <.user_menu current_user={@current_user} />
            <% else %>
              <.auth_links />
            <% end %>
          </div>
        </div>
      </div>

      <%!-- Mobile Navigation Menu Button --%>
      <div class="sm:hidden">
        <button
          type="button"
          class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500"
          phx-click={JS.toggle(to: "#mobile-menu")}
        >
          <span class="sr-only">Open main menu</span>
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>
    </nav>

    <%!-- Mobile Menu Content --%>
    <div class="sm:hidden hidden" id="mobile-menu">
      <div class="pt-2 pb-3 space-y-1">
        <%= if @current_user do %>
          <%!-- Content Section --%>
          <div class="px-3 py-1 text-xs font-semibold text-gray-500 uppercase tracking-wider">
            Content
          </div>
          <.mobile_nav_link patch="/problems" active={current_path(assigns) =~ "/problems"}>Problems</.mobile_nav_link>
          <.mobile_nav_link patch="/solutions" active={current_path(assigns) =~ "/solutions"}>Solutions</.mobile_nav_link>
          <.mobile_nav_link patch="/lessons" active={current_path(assigns) =~ "/lessons"}>Lessons</.mobile_nav_link>
          <.mobile_nav_link patch="/advantages" active={current_path(assigns) =~ "/advantages"}>Advantages</.mobile_nav_link>
          <.mobile_nav_link patch="/theorems" active={current_path(assigns) =~ "/theorems"}>Theorems</.mobile_nav_link>
          <.mobile_nav_link patch="/topics" active={current_path(assigns) =~ "/topics"}>Topics</.mobile_nav_link>
          <.mobile_nav_link patch="/qa" active={current_path(assigns) =~ "/qa"}>Q&A</.mobile_nav_link>

          <%!-- Management Section --%>
          <div class="px-3 py-1 text-xs font-semibold text-gray-500 uppercase tracking-wider">
            Risk Management
          </div>
          <.mobile_nav_link patch="/risks" active={current_path(assigns) =~ "/risks"}>Risks</.mobile_nav_link>
          <.mobile_nav_link patch="/impacts" active={current_path(assigns) =~ "/impacts"}>Impacts</.mobile_nav_link>
          <.mobile_nav_link patch="/mitigations" active={current_path(assigns) =~ "/mitigations"}>Mitigations</.mobile_nav_link>
          <.mobile_nav_link patch="/categories" active={current_path(assigns) =~ "/categories"}>Categories</.mobile_nav_link>

          <div class="px-3 py-1 text-xs font-semibold text-gray-500 uppercase tracking-wider">
            Project Management
          </div>
          <.mobile_nav_link patch="/projects" active={current_path(assigns) =~ "/projects"}>Projects</.mobile_nav_link>
          <.mobile_nav_link patch="/requirements" active={current_path(assigns) =~ "/requirements"}>Requirements</.mobile_nav_link>
          <.mobile_nav_link patch="/resources" active={current_path(assigns) =~ "/resources"}>Resources</.mobile_nav_link>
          <.mobile_nav_link patch="/documents" active={current_path(assigns) =~ "/documents"}>Documents</.mobile_nav_link>

          <%!-- Tools Section --%>
          <div class="px-3 py-1 text-xs font-semibold text-gray-500 uppercase tracking-wider">
            Tools
          </div>
          <.mobile_nav_link patch="/suppliers" active={current_path(assigns) =~ "/suppliers"}>Suppliers</.mobile_nav_link>
          <.mobile_nav_link patch="/inventory" active={current_path(assigns) =~ "/inventory"}>Inventory</.mobile_nav_link>
          <.mobile_nav_link patch="/actors" active={current_path(assigns) =~ "/actors"}>Actors</.mobile_nav_link>
          <.mobile_nav_link patch="/rewards" active={current_path(assigns) =~ "/rewards"}>Rewards</.mobile_nav_link>

          <%!-- Other Links --%>
          <div class="px-3 py-1 text-xs font-semibold text-gray-500 uppercase tracking-wider">
            Other
          </div>
          <.mobile_nav_link patch="/events" active={current_path(assigns) =~ "/events"}>Events</.mobile_nav_link>
          <.mobile_nav_link patch="/messages" active={current_path(assigns) =~ "/messages"}>Messages</.mobile_nav_link>

          <%= if @current_user.is_admin do %>
            <.mobile_nav_link patch="/analytics" active={current_path(assigns) =~ "/analytics"}>Analytics</.mobile_nav_link>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  # New dropdown link component
  attr :patch, :string, required: true
  slot :inner_block, required: true

  def nav_dropdown_link(assigns) do
    ~H"""
    <.link
      patch={@patch}
      class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # Navigation link component
  attr :patch, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  def nav_link(assigns) do
    ~H"""
    <.link
      patch={@patch}
      class={[
        "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium",
        @active && "border-blue-500 text-gray-900",
        !@active && "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
      ]}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # User menu component
  attr :current_user, :map, required: true

  def user_menu(assigns) do
    ~H"""
    <div class="relative ml-3">
      <div>
        <button
          type="button"
          class="flex items-center max-w-xs text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          phx-click={JS.toggle(to: "#user-menu-items")}
        >
          <span class="sr-only">Open user menu</span>
          <div class="h-8 w-8 rounded-full bg-gray-200 flex items-center justify-center">
            <span class="text-gray-600 font-medium">
              <%= String.first(@current_user.email) %>
            </span>
          </div>
        </button>
      </div>
      <div
        id="user-menu-items"
        class="hidden origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 focus:outline-none"
      >
        <.link
          navigate="/settings"
          class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
        >
          Settings
        </.link>
        <.link
          href="/users/log_out"
          method="delete"
          class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
        >
          Log out
        </.link>
      </div>
    </div>
    """
  end

  def auth_links(assigns) do
    ~H"""
    <div class="flex items-center space-x-4">
      <.link
        navigate="/users/register"
        class="text-gray-500 hover:text-gray-700"
      >
        Register
      </.link>
      <.link
        navigate="/users/log_in"
        class="text-gray-500 hover:text-gray-700"
      >
        Log in
      </.link>
    </div>
    """
  end

  # Mobile navigation link component
  attr :patch, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  def mobile_nav_link(assigns) do
    ~H"""
    <.link
      patch={@patch}
      class={[
        "block pl-3 pr-4 py-2 border-l-4 text-base font-medium",
        @active && "bg-blue-50 border-blue-500 text-blue-700",
        !@active && "border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700"
      ]}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # Helper functions
  defp current_path(assigns) do
    assigns.current_uri && URI.parse(assigns.current_uri).path || "/"
  end
end
