defmodule Resolvinator.Fabric.Lakehouse do
  @moduledoc """
  Handles data storage and retrieval from Microsoft Fabric's Lakehouse
  """

  def store_problem_analysis(problem_id, analysis_results) do
    data = Explorer.DataFrame.new(%{
      problem_id: [problem_id],
      timestamp: [DateTime.utc_now()],
      similar_events: [analysis_results.similar_events],
      risk_assessment: [analysis_results.risk_assessment],
      recommended_actions: [analysis_results.recommended_actions],
      prevention_measures: [analysis_results.prevention_measures]
    })

    Explorer.DataFrame.to_parquet!(
      data,
      "problem_analysis/#{problem_id}/#{timestamp()}.parquet",
      storage_options: azure_credentials()
    )
  end

  def get_latest_analysis(problem_id) do
    path = "problem_analysis/#{problem_id}/latest.parquet"

    Explorer.DataFrame.from_parquet!(
      "abfs://#{container()}/#{path}",
      storage_options: azure_credentials()
    )
    |> Explorer.DataFrame.to_rows()
    |> List.first()
  end

  defp azure_credentials do
    %{
      "account_name" => System.get_env("AZURE_STORAGE_ACCOUNT"),
      "account_key" => System.get_env("AZURE_STORAGE_KEY")
    }
  end

  defp container, do: System.get_env("AZURE_STORAGE_CONTAINER")
  
  defp timestamp do
    DateTime.utc_now()
    |> Calendar.strftime("%Y%m%d_%H%M%S")
  end
end 