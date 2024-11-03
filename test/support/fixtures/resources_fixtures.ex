defmodule Resolvinator.ResourcesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Resources` context.
  """

  @doc """
  Generate a resource.
  """
  def resource_fixture(attrs \\ %{}) do
    {:ok, resource} =
      attrs
      |> Enum.into(%{
        availability_status: "some availability_status",
        cost_per_unit: "120.5",
        description: "some description",
        metadata: %{},
        name: "some name",
        quantity: "120.5",
        type: "some type",
        unit: "some unit"
      })
      |> Resolvinator.Resources.create_resource()

    resource
  end
end
