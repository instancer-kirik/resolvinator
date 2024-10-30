defmodule Resolvinator.RisksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Risks` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        assessment_criteria: %{},
        color: "some color",
        description: "some description",
        name: "some name"
      })
      |> Resolvinator.Risks.create_category()

    category
  end

  @doc """
  Generate a risk.
  """
  def risk_fixture(attrs \\ %{}) do
    {:ok, risk} =
      attrs
      |> Enum.into(%{
        description: "some description",
        detection_date: ~D[2024-10-29],
        impact: "some impact",
        mitigation_status: "some mitigation_status",
        name: "some name",
        priority: "some priority",
        probability: "some probability",
        review_date: ~D[2024-10-29],
        status: "some status"
      })
      |> Resolvinator.Risks.create_risk()

    risk
  end

  @doc """
  Generate a impact.
  """
  def impact_fixture(attrs \\ %{}) do
    {:ok, impact} =
      attrs
      |> Enum.into(%{
        area: "some area",
        description: "some description",
        estimated_cost: "120.5",
        likelihood: "some likelihood",
        notes: "some notes",
        severity: "some severity",
        timeframe: "some timeframe"
      })
      |> Resolvinator.Risks.create_impact()

    impact
  end

  @doc """
  Generate a mitigation.
  """
  def mitigation_fixture(attrs \\ %{}) do
    {:ok, mitigation} =
      attrs
      |> Enum.into(%{
        completion_date: ~D[2024-10-29],
        cost: "120.5",
        description: "some description",
        effectiveness: "some effectiveness",
        notes: "some notes",
        start_date: ~D[2024-10-29],
        status: "some status",
        strategy: "some strategy",
        target_date: ~D[2024-10-29]
      })
      |> Resolvinator.Risks.create_mitigation()

    mitigation
  end

  @doc """
  Generate a mitigation_task.
  """
  def mitigation_task_fixture(attrs \\ %{}) do
    {:ok, mitigation_task} =
      attrs
      |> Enum.into(%{
        completion_date: ~D[2024-10-29],
        description: "some description",
        due_date: ~D[2024-10-29],
        name: "some name",
        status: "some status"
      })
      |> Resolvinator.Risks.create_mitigation_task()

    mitigation_task
  end
end
