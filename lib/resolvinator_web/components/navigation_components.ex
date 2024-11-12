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
                <.nav_link patch="/problems" active={current_path(assigns) =~ "/problems"}>
                  Problems
                </.nav_link>
                <.nav_link patch="/solutions" active={current_path(assigns) =~ "/solutions"}>
                  Solutions
                </.nav_link>
                <.nav_link patch="/risks" active={current_path(assigns) =~ "/risks"}>
                  Risks
                </.nav_link>
                <.nav_link patch="/events" active={current_path(assigns) =~ "/events"}>
                  Events
                </.nav_link>
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
    </nav>
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

  # Helper functions
  defp current_path(assigns) do
    URI.parse(assigns.current_uri).path
  end
end
