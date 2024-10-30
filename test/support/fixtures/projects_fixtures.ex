defmodule Resolvinator.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        completion_date: ~D[2024-10-29],
        description: "some description",
        name: "some name",
        risk_appetite: "some risk_appetite",
        settings: %{},
        start_date: ~D[2024-10-29],
        status: "some status",
        target_date: ~D[2024-10-29]
      })
      |> Resolvinator.Projects.create_project()

    project
  end
end
