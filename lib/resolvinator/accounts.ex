defmodule Resolvinator.Acts do
  @moduledoc """
  The Accounts context.
  Delegates to Acts for core user management while handling Resolvinator-specific concerns.
  """

  import Ecto.Query, warn: false
  alias Acts
  alias Acts.User
  alias VES.Repo

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email_or_register(email) when is_binary(email) do
    case get_user_by_email(email) do
      nil ->
        # Generate a random password for new users
        pw = :rand.bytes(30) |> Base.encode64(padding: false)
        
        # Register user with both core and Resolvinator profile
        {:ok, %{user: user}} = Accounts.Auth.register_user(
          %{email: email, password: pw},
          %{
            resolvinator: %{
              display_name: email |> String.split("@") |> hd(),
              preferences: %{},
              notification_settings: %{email_notifications: true}
            }
          }
        )
        user
        
      user -> user
    end
  end

  @doc """
  Gets a user by email and password.
  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    case Accounts.Auth.authenticate_user(email, password) do
      {:ok, user} -> user
      _ -> nil
    end
  end

  @doc """
  Gets a single user.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  """
  def register_user(attrs) do
    # Register user with both core and Resolvinator profile
    Accounts.Auth.register_user(
      attrs,
      %{
        resolvinator: %{
          display_name: attrs[:email] |> String.split("@") |> hd(),
          preferences: %{},
          notification_settings: %{email_notifications: true}
        }
      }
    )
  end

  @doc """
  Updates a user's email.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  @doc """
  Delivers the update email instructions to the given user.
  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.
  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.
  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Helpers

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end
end
