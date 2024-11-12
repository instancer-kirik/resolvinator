defmodule Resolvinator.AI.FabricClient do
  @moduledoc """
  Client for interacting with Microsoft Fabric/Power BI REST API.
  Requires Azure AD application with appropriate Power BI permissions.
  """

  require Logger

  @fabric_endpoint "https://api.powerbi.com/v1.0/myorg"
  
  # Azure AD configuration
  @tenant_id Application.compile_env(:resolvinator, :azure_tenant_id)
  @client_id Application.compile_env(:resolvinator, :azure_client_id)
  @client_secret Application.compile_env(:resolvinator, :azure_client_secret)

  @doc """
  Gets an access token from Azure AD using client credentials flow.
  Requires CLIENT_ID, CLIENT_SECRET, and TENANT_ID to be configured.
  """
  def get_access_token do
    token_url = "https://login.microsoftonline.com/#{@tenant_id}/oauth2/v2.0/token"
    
    body = URI.encode_query(%{
      "client_id" => @client_id,
      "client_secret" => @client_secret,
      "scope" => "https://analysis.windows.net/powerbi/api/.default",
      "grant_type" => "client_credentials"
    })

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    Logger.debug("Requesting access token from Azure AD")

    case HTTPoison.post(token_url, body, headers) do
      {:ok, %{status_code: 200, body: resp_body}} ->
        case Jason.decode(resp_body) do
          {:ok, %{"access_token" => token}} ->
            Logger.debug("Successfully obtained access token")
            {:ok, token}
          
          {:error, decode_error} ->
            Logger.error("Failed to decode token response: #{inspect(decode_error)}")
            {:error, "Failed to decode token response"}
        end

      {:ok, %{status_code: status_code, body: body}} ->
        Logger.error("Failed to obtain access token. Status: #{status_code}, Body: #{body}")
        {:error, "Failed to obtain access token: HTTP #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Network error while obtaining token: #{inspect(reason)}")
        {:error, "Network error while obtaining token"}
    end
  end

  @doc """
  Lists all workspaces accessible to the service principal.
  """
  def list_workspaces do
    get("/groups")
  end

  @doc """
  Gets details about a specific workspace.
  """
  def get_workspace(workspace_id) do
    get("/groups/#{workspace_id}")
  end

  @doc """
  Lists all datasets in a workspace.
  """
  def list_datasets(workspace_id) do
    get("/groups/#{workspace_id}/datasets")
  end

  @doc """
  Lists all reports in a workspace.
  """
  def list_reports(workspace_id) do
    get("/groups/#{workspace_id}/reports")
  end

  defp get(path) do
    with {:ok, token} <- get_access_token(),
         {:ok, response} <- do_request(:get, path, nil, token) do
      {:ok, response}
    end
  end

  defp post(path, params) do
    with {:ok, token} <- get_access_token(),
         {:ok, response} <- do_request(:post, path, params, token) do
      {:ok, response}
    end
  end

  defp do_request(method, path, params, token) do
    url = @fabric_endpoint <> path
    
    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"}
    ]

    body = if params, do: Jason.encode!(params), else: ""

    Logger.debug("Making #{method} request to: #{url}")
    if params, do: Logger.debug("Request body: #{body}")

    case apply(HTTPoison, method, [url, body, headers]) do
      {:ok, %{status_code: status_code, body: resp_body}} when status_code in 200..299 ->
        Logger.debug("Successful response from API")
        case Jason.decode(resp_body) do
          {:ok, decoded} -> {:ok, decoded}
          {:error, _} -> {:ok, resp_body}  # Handle empty responses
        end

      {:ok, %{status_code: status_code, body: resp_body}} ->
        Logger.error("API error: #{status_code} - #{resp_body}")
        {:error, "API error: #{status_code} - #{resp_body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Network error: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}
    end
  end
end
