defmodule ResolvinatorWeb.UserRegistrationLive do
  use ResolvinatorWeb, :live_view

  alias Acts
  alias Acts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for VES
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/register"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input field={@form[:username]} type="text" label="Username (optional)" />
        <input type="hidden" name="_action" value="register" />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>

      <div class="mt-8">
        <.button
          phx-click="github_register"
          class="w-full flex items-center justify-center space-x-2"
        >
          <span class="text-lg">
            <.icon name="hero-code-bracket" class="h-5 w-5" />
          </span>
          <span>Sign up with GitHub</span>
        </.button>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.Registration.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    # Generate username from email if not provided
    user_params = if user_params["username"] == "" do
      Map.put(user_params, "username", generate_username(user_params["email"]))
    else
      user_params
    end

    case Accounts.Registration.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.Registration.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.Registration.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("github_register", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/auth/github")}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  defp generate_username(email) when is_binary(email) do
    email
    |> String.split("@")
    |> List.first()
    |> String.replace(~r/[^a-zA-Z0-9]/, "")
    |> String.downcase()
  end
  defp generate_username(_), do: nil
end
