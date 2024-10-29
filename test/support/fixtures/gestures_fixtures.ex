defmodule Resolvinator.GesturesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Gestures` context.
  """

  @doc """
  Generate a gesture.
  """
  def gesture_fixture(attrs \\ %{}) do
    {:ok, gesture} =
      attrs
      |> Enum.into(%{
        description: "some description",
        fingers: "some fingers",
        name: "some name",
        svg: "some svg"
      })
      |> Resolvinator.Gestures.create_gesture()

    gesture
  end
end
