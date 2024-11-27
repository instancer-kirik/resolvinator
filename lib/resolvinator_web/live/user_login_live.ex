defmodule ResolvinatorWeb.UserLoginLive do
  use ResolvinatorWeb, :live_view

  alias Acts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to VES
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="login_form"
        action={~p"/users/log_in"}
        phx-update="ignore"
        phx-submit="login"
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>

      <div class="mt-8">
        <.button
          phx-click="github_login"
          class="w-full flex items-center justify-center space-x-2"
        >
          <span class="text-lg">
            <.icon name="hero-code-bracket" class="h-5 w-5" />
          </span>
          <span>Continue with GitHub</span>
        </.button>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end

  def handle_event("login", %{"user" => user_params}, socket) do
    case Accounts.Auth.authenticate_user(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Welcome back!")
         |> ResolvinatorWeb.UserAuth.log_in_user(user, user_params)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid email or password")
         |> assign(form: to_form(%{"email" => user_params["email"]}, as: "user"))}
    end
  end

  def handle_event("github_login", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/auth/github")}
  end
end
