defmodule Resolvinator.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Content` context.
  """

  @doc """
  Generate a problem.
  """
  def problem_fixture(attrs \\ %{}) do
    {:ok, problem} =
      attrs
      |> Enum.into(%{
        desc: "some desc",
        downvotes: 42,
        name: "some name",
        upvotes: 42
      })
      |> Resolvinator.Content.create_problem()

    problem
  end

  @doc """
  Generate a advantage.
  """
  def advantage_fixture(attrs \\ %{}) do
    {:ok, advantage} =
      attrs
      |> Enum.into(%{
        desc: "some desc",
        downvotes: 42,
        name: "some name",
        upvotes: 42
      })
      |> Resolvinator.Content.create_advantage()

    advantage
  end

  @doc """
  Generate a solution.
  """
  def solution_fixture(attrs \\ %{}) do
    {:ok, solution} =
      attrs
      |> Enum.into(%{
        desc: "some desc",
        downvotes: 42,
        name: "some name",
        upvotes: 42
      })
      |> Resolvinator.Content.create_solution()

    solution
  end

  @doc """
  Generate a lesson.
  """
  def lesson_fixture(attrs \\ %{}) do
    {:ok, lesson} =
      attrs
      |> Enum.into(%{
        desc: "some desc",
        downvotes: 42,
        name: "some name",
        upvotes: 42
      })
      |> Resolvinator.Content.create_lesson()

    lesson
  end
end
