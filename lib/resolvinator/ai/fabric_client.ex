defmodule Resolvinator.AI.FabricClient do
  @moduledoc """
  Client for interacting with Microsoft Fabric APIs.
  """

  @fabric_endpoint Application.compile_env(:resolvinator, :fabric_endpoint)
  @fabric_key Application.compile_env(:resolvinator, :fabric_key)

  def analyze_schema(params) do
    post("/analyze/schema", params)
  end

  def suggest_types(params) do
    post("/suggest/types", params)
  end

  def generate_validations(params) do
    post("/generate/validations", params)
  end

  defp post(path, params) do
    headers = [
      {"Authorization", "Bearer #{@fabric_key}"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post("#{@fabric_endpoint}#{path}", Jason.encode!(params), headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %{status_code: status_code, body: body}} ->
        {:error, "Fabric API error: #{status_code} - #{body}"}
      {:error, error} ->
        {:error, "Network error: #{inspect(error)}"}
    end
  end
end
