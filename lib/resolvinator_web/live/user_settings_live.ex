defmodule ResolvinatorWeb.UserSettingsLive do
  use ResolvinatorWeb, :live_view

  alias VES.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      VES Account Settings
      <:subtitle>Manage your account settings and connected applications</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>

      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>

      <div>
        <.header class="text-left text-lg font-semibold leading-8 text-zinc-800">
          Connected Applications
          <:subtitle>Manage your connected GitHub and other application accounts</:subtitle>
        </.header>

        <div class="mt-6 flex flex-col gap-4">
          <div :if={@github_connected} class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <.icon name="hero-code-bracket" class="h-8 w-8" />
              <div>
                <p class="text-sm font-semibold">GitHub</p>
                <p class="text-xs text-zinc-500">Connected as <%= @github_username %></p>
              </div>
            </div>
            <.button phx-click="disconnect_github" class="text-sm">Disconnect</.button>
          </div>

          <div :if={!@github_connected} class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <.icon name="hero-code-bracket" class="h-8 w-8" />
              <div>
                <p class="text-sm font-semibold">GitHub</p>
                <p class="text-xs text-zinc-500">Not connected</p>
              </div>
            </div>
            <.button phx-click="connect_github" class="text-sm">Connect</.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.Auth.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.Auth.change_user_email(user)
    password_changeset = Accounts.Auth.change_user_password(user)

    github_info = Accounts.get_github_info(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:github_connected, github_info != nil)
      |> assign(:github_username, if(github_info, do: github_info.username, else: nil))

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.Auth.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.Auth.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.Auth.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.Auth.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.Auth.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("connect_github", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/auth/github")}
  end

  def handle_event("disconnect_github", _params, socket) do
    case Accounts.disconnect_github(socket.assigns.current_user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "GitHub account disconnected successfully.")
         |> assign(:github_connected, false)
         |> assign(:github_username, nil)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to disconnect GitHub account.")}
    end
  end
end
