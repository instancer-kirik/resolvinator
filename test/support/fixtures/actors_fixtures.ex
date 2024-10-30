defmodule Resolvinator.ActorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Actors` context.
  """

  @doc """
  Generate a actor.
  """
  def actor_fixture(attrs \\ %{}) do
    {:ok, actor} =
      attrs
      |> Enum.into(%{
        contact_info: %{},
        description: "some description",
        influence_level: "some influence_level",
        name: "some name",
        role: "some role",
        status: "some status",
        type: "some type"
      })
      |> Resolvinator.Actors.create_actor()

    actor
  end
end
