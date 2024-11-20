defmodule ResolvinatorWeb.GithubAuthController do
  use ResolvinatorWeb, :controller

  alias VES.Accounts
  alias ResolvinatorWeb.UserAuth

  @doc """
  Initiates the GitHub OAuth flow by redirecting to GitHub's authorization endpoint
  """
  def request(conn, _params) do
    redirect_uri = url(~p"/auth/github/callback")
    
    conn
    |> put_session(:github_redirect_uri, redirect_uri)
    |> redirect(external: Accounts.GitHub.authorize_url(redirect_uri))
  end

  @doc """
  Handles the OAuth callback from GitHub, authenticates the user, and creates/updates
  their account with GitHub information
  """
  def callback(conn, %{"code" => code}) do
    redirect_uri = get_session(conn, :github_redirect_uri)
    
    case Accounts.GitHub.exchange_code_for_token(code, redirect_uri) do
      {:ok, github_token} ->
        case Accounts.GitHub.get_user_profile(github_token) do
          {:ok, github_user} ->
            case Accounts.GitHub.find_or_create_user(github_user, github_token) do
              {:ok, user} ->
                conn
                |> delete_session(:github_redirect_uri)
                |> UserAuth.log_in_user(user)

              {:error, _reason} ->
                conn
                |> put_flash(:error, "Failed to create user from GitHub account.")
                |> redirect(to: ~p"/users/log_in")
            end

          {:error, _reason} ->
            conn
            |> put_flash(:error, "Failed to fetch GitHub profile.")
            |> redirect(to: ~p"/users/log_in")
        end

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Failed to authenticate with GitHub.")
        |> redirect(to: ~p"/users/log_in")
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Invalid GitHub callback.")
    |> redirect(to: ~p"/users/log_in")
  end
end
