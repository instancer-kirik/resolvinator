defmodule ResolvinatorWeb.UserRegistrationController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Acts
  alias ResolvinatorWeb.UserAuth

  def create(conn, params) do
    IO.inspect(params, label: "Full registration params")
    
    case params do
      %{"user" => user_params} ->
        IO.inspect(user_params, label: "User registration params")
        
        # Add username if not present
        user_params = Map.put_new(user_params, "username", generate_username(user_params["email"]))
        IO.inspect(user_params, label: "Registration params with username")

        case Accounts.register_user(user_params) do
          {:ok, user} ->
            IO.inspect(user, label: "Successfully registered user")
            {:ok, _} =
              Accounts.deliver_user_confirmation_instructions(
                user,
                &url(~p"/users/confirm/#{&1}")
              )

            conn
            |> put_flash(:info, "User created successfully.")
            |> UserAuth.log_in_user(user)
            |> redirect(to: ~p"/")  # Add explicit redirect

          {:error, %Ecto.Changeset{} = changeset} ->
            IO.inspect(changeset.errors, label: "Registration errors")
            IO.inspect(changeset.changes, label: "Failed changes")
            conn
            |> put_flash(:error, "Registration failed: #{error_to_string(changeset)}")
            |> redirect(to: ~p"/users/register")
        end
      
      _ ->
        IO.inspect("Invalid params structure")
        conn
        |> put_flash(:error, "Invalid registration parameters")
        |> redirect(to: ~p"/users/register")
    end
  end

  defp generate_username(email) when is_binary(email) do
    email
    |> String.split("@")
    |> List.first()
    |> String.replace(~r/[^a-zA-Z0-9_.-]/, "")
  end

  defp error_to_string(changeset) do
    Enum.map(changeset.errors, fn {field, {msg, _opts}} ->
      "#{field} #{msg}"
    end)
    |> Enum.join(", ")
  end
end 