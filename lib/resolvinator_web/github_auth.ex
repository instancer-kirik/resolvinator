defmodule ResolvinatorWeb.GithubAuth do
  import Plug.Conn

  alias Assent.{Config, Strategy.Github}
  alias Acts
  alias Acts.User

  @doc """
  Initiates the GitHub OAuth flow by redirecting to GitHub's authorization URL.
  """
  def request(conn) do
    Application.get_env(:assent, :github)
    |> Github.authorize_url()
    |> case do
      {:ok, %{url: url, session_params: session_params}} ->
        conn
        |> put_session(:session_params, session_params)
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, error} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, "Error generating authorization URL: #{inspect(error)}")
    end
  end

  @doc """
  Handles the GitHub OAuth callback and creates/updates the user account.
  """
  def callback(conn) do
    %{params: params} = fetch_query_params(conn)
    session_params = get_session(conn, :session_params)

    Application.get_env(:assent, :github)
    |> Config.put(:session_params, session_params)
    |> Github.callback(params)
    |> case do
      {:ok, %{user: github_user, token: token}} ->
        # Get or create user with GitHub profile
        {:ok, %{user: user}} = get_or_create_user(github_user)

        conn
        |> ResolvinatorWeb.UserAuth.log_in_user(user)
        |> put_session(:github_user, github_user)
        |> put_session(:github_token, token)
        |> Phoenix.Controller.redirect(to: "/")

      {:error, error} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, inspect(error, pretty: true))
    end
  end

  @doc """
  Fetches the current GitHub user from the session.
  """
  def fetch_github_user(conn, _opts) do
    with user when is_map(user) <- get_session(conn, :github_user),
         {:ok, ves_user} <- get_or_create_user(user) do
      assign(conn, :current_user, ves_user)
    else
      _ -> conn
    end
  end

  @doc """
  Handles mounting the current user in LiveView contexts.
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  # Private Functions

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      with user when is_map(user) <- session["github_user"],
           {:ok, ves_user} <- get_or_create_user(user) do
        ves_user
      else
        _ -> nil
      end
    end)
  end

  defp get_or_create_user(github_user) do
    case Accounts.Auth.register_user(
      %{
        email: github_user["email"],
        password: generate_random_password()
      },
      %{
        resolvinator: %{
          display_name: github_user["login"] || (github_user["email"] |> String.split("@") |> hd()),
          preferences: %{},
          notification_settings: %{email_notifications: true},
          github_info: %{
            login: github_user["login"],
            avatar_url: github_user["avatar_url"],
            html_url: github_user["html_url"],
            name: github_user["name"]
          }
        }
      }
    ) do
      {:ok, result} -> {:ok, result}
      {:error, :user, %{errors: [email: {"has already been taken", _}]}, _} ->
        # User exists, fetch and return
        {:ok, %{user: Accounts.Auth.get_user_by_email!(github_user["email"])}}
      error -> error
    end
  end

  defp generate_random_password do
    :crypto.strong_rand_bytes(32) |> Base.encode64(padding: false)
  end
end
