defmodule Resolvinator.GitHub do
  @moduledoc """
  Handles GitHub repository operations and integration with Deepscape workspace.
  """

  alias Tentacat.Client
  require Logger

  @default_workspace_path Application.compile_env(:resolvinator, :workspace_path, "/tmp/resolvinator_workspace")

  def clone_repository(repo_url, opts \\ []) do
    branch = Keyword.get(opts, :branch, "main")
    custom_path = Keyword.get(opts, :path)
    
    with {:ok, repo_path} <- prepare_workspace(repo_url, custom_path),
         {:ok, _} <- Git.clone([repo_url, repo_path]),
         {:ok, _} <- Git.checkout(["-b", branch], cd: repo_path) do
      {:ok, repo_path}
    else
      error ->
        Logger.error("Failed to clone repository: #{inspect(error)}")
        error
    end
  end

  def open_in_deepscape(repo_path) do
    Deepscape.open_workspace(repo_path)
  end

  def list_workspaces do
    case File.ls(@default_workspace_path) do
      {:ok, files} -> {:ok, files}
      {:error, _} -> {:ok, []}
    end
  end

  defp prepare_workspace(repo_url, custom_path) do
    repo_name = extract_repo_name(repo_url)
    repo_path = if custom_path do
      Path.join(custom_path, repo_name)
    else
      Path.join(@default_workspace_path, repo_name)
    end
    
    base_path = Path.dirname(repo_path)
    
    with :ok <- File.mkdir_p(base_path),
         {:ok, _} <- clean_existing_repo(repo_path) do
      {:ok, repo_path}
    end
  end

  defp clean_existing_repo(repo_path) do
    case File.rm_rf(repo_path) do
      {:ok, _} -> {:ok, repo_path}
      error -> error
    end
  end

  defp extract_repo_name(repo_url) do
    repo_url
    |> String.split("/")
    |> List.last()
    |> String.replace(".git", "")
  end
end
