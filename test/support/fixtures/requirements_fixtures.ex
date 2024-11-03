defmodule Resolvinator.RequirementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Requirements` context.
  """

  @doc """
  Generate a requirement.
  """
  def requirement_fixture(attrs \\ %{}) do
    {:ok, requirement} =
      attrs
      |> Enum.into(%{
        description: "some description",
        due_date: ~D[2024-11-02],
        name: "some name",
        priority: "some priority",
        status: "some status",
        type: "some type",
        validation_criteria: "some validation_criteria"
      })
      |> Resolvinator.Requirements.create_requirement()

    requirement
  end
end
