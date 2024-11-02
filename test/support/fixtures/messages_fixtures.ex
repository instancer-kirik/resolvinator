defmodule Resolvinator.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content",
        read: true
      })
      |> Resolvinator.Messages.create_message()

    message
  end
end
