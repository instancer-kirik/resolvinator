defmodule ResolvinatorWeb.UserRegistrationLive do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Accounts
  alias Resolvinator.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
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
        <input type="hidden" name="_action" value="register" />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    IO.inspect(user_params, label: "Live view save params")
    
    # Generate username from email if not provided
    user_params = user_params
      |> Map.put("username", generate_username(user_params["email"]))
      |> IO.inspect(label: "Live view params with username")

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        IO.inspect(user, label: "Live view registration success")
        
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors, label: "Live view registration errors")
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    # Add username during validation too
    user_params = Map.put_new(user_params, "username", generate_username(user_params["email"]))
    IO.inspect(user_params, label: "Validation params")
    
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
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
    username = email
      |> String.split("@")
      |> List.first()
      |> String.replace(~r/[^a-zA-Z0-9_.-]/, "")
    
    IO.inspect(username, label: "Generated username")
    username
  end
  defp generate_username(_), do: nil
end
