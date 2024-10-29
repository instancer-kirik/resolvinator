defmodule Resolvinator.ContentTest do
  use Resolvinator.DataCase

  alias Resolvinator.Content

  describe "problems" do
    alias Resolvinator.Content.Problem

    import Resolvinator.ContentFixtures

    @invalid_attrs %{name: nil, desc: nil, upvotes: nil, downvotes: nil}

    test "list_problems/0 returns all problems" do
      problem = problem_fixture()
      assert Content.list_problems() == [problem]
    end

    test "get_problem!/1 returns the problem with given id" do
      problem = problem_fixture()
      assert Content.get_problem!(problem.id) == problem
    end

    test "create_problem/1 with valid data creates a problem" do
      valid_attrs = %{name: "some name", desc: "some desc", upvotes: 42, downvotes: 42}

      assert {:ok, %Problem{} = problem} = Content.create_problem(valid_attrs)
      assert problem.name == "some name"
      assert problem.desc == "some desc"
      assert problem.upvotes == 42
      assert problem.downvotes == 42
    end

    test "create_problem/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_problem(@invalid_attrs)
    end

    test "update_problem/2 with valid data updates the problem" do
      problem = problem_fixture()
      update_attrs = %{name: "some updated name", desc: "some updated desc", upvotes: 43, downvotes: 43}

      assert {:ok, %Problem{} = problem} = Content.update_problem(problem, update_attrs)
      assert problem.name == "some updated name"
      assert problem.desc == "some updated desc"
      assert problem.upvotes == 43
      assert problem.downvotes == 43
    end

    test "update_problem/2 with invalid data returns error changeset" do
      problem = problem_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_problem(problem, @invalid_attrs)
      assert problem == Content.get_problem!(problem.id)
    end

    test "delete_problem/1 deletes the problem" do
      problem = problem_fixture()
      assert {:ok, %Problem{}} = Content.delete_problem(problem)
      assert_raise Ecto.NoResultsError, fn -> Content.get_problem!(problem.id) end
    end

    test "change_problem/1 returns a problem changeset" do
      problem = problem_fixture()
      assert %Ecto.Changeset{} = Content.change_problem(problem)
    end
  end

  describe "advantages" do
    alias Resolvinator.Content.Advantage

    import Resolvinator.ContentFixtures

    @invalid_attrs %{name: nil, desc: nil, upvotes: nil, downvotes: nil}

    test "list_advantages/0 returns all advantages" do
      advantage = advantage_fixture()
      assert Content.list_advantages() == [advantage]
    end

    test "get_advantage!/1 returns the advantage with given id" do
      advantage = advantage_fixture()
      assert Content.get_advantage!(advantage.id) == advantage
    end

    test "create_advantage/1 with valid data creates a advantage" do
      valid_attrs = %{name: "some name", desc: "some desc", upvotes: 42, downvotes: 42}

      assert {:ok, %Advantage{} = advantage} = Content.create_advantage(valid_attrs)
      assert advantage.name == "some name"
      assert advantage.desc == "some desc"
      assert advantage.upvotes == 42
      assert advantage.downvotes == 42
    end

    test "create_advantage/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_advantage(@invalid_attrs)
    end

    test "update_advantage/2 with valid data updates the advantage" do
      advantage = advantage_fixture()
      update_attrs = %{name: "some updated name", desc: "some updated desc", upvotes: 43, downvotes: 43}

      assert {:ok, %Advantage{} = advantage} = Content.update_advantage(advantage, update_attrs)
      assert advantage.name == "some updated name"
      assert advantage.desc == "some updated desc"
      assert advantage.upvotes == 43
      assert advantage.downvotes == 43
    end

    test "update_advantage/2 with invalid data returns error changeset" do
      advantage = advantage_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_advantage(advantage, @invalid_attrs)
      assert advantage == Content.get_advantage!(advantage.id)
    end

    test "delete_advantage/1 deletes the advantage" do
      advantage = advantage_fixture()
      assert {:ok, %Advantage{}} = Content.delete_advantage(advantage)
      assert_raise Ecto.NoResultsError, fn -> Content.get_advantage!(advantage.id) end
    end

    test "change_advantage/1 returns a advantage changeset" do
      advantage = advantage_fixture()
      assert %Ecto.Changeset{} = Content.change_advantage(advantage)
    end
  end

  describe "solutions" do
    alias Resolvinator.Content.Solution

    import Resolvinator.ContentFixtures

    @invalid_attrs %{name: nil, desc: nil, upvotes: nil, downvotes: nil}

    test "list_solutions/0 returns all solutions" do
      solution = solution_fixture()
      assert Content.list_solutions() == [solution]
    end

    test "get_solution!/1 returns the solution with given id" do
      solution = solution_fixture()
      assert Content.get_solution!(solution.id) == solution
    end

    test "create_solution/1 with valid data creates a solution" do
      valid_attrs = %{name: "some name", desc: "some desc", upvotes: 42, downvotes: 42}

      assert {:ok, %Solution{} = solution} = Content.create_solution(valid_attrs)
      assert solution.name == "some name"
      assert solution.desc == "some desc"
      assert solution.upvotes == 42
      assert solution.downvotes == 42
    end

    test "create_solution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_solution(@invalid_attrs)
    end

    test "update_solution/2 with valid data updates the solution" do
      solution = solution_fixture()
      update_attrs = %{name: "some updated name", desc: "some updated desc", upvotes: 43, downvotes: 43}

      assert {:ok, %Solution{} = solution} = Content.update_solution(solution, update_attrs)
      assert solution.name == "some updated name"
      assert solution.desc == "some updated desc"
      assert solution.upvotes == 43
      assert solution.downvotes == 43
    end

    test "update_solution/2 with invalid data returns error changeset" do
      solution = solution_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_solution(solution, @invalid_attrs)
      assert solution == Content.get_solution!(solution.id)
    end

    test "delete_solution/1 deletes the solution" do
      solution = solution_fixture()
      assert {:ok, %Solution{}} = Content.delete_solution(solution)
      assert_raise Ecto.NoResultsError, fn -> Content.get_solution!(solution.id) end
    end

    test "change_solution/1 returns a solution changeset" do
      solution = solution_fixture()
      assert %Ecto.Changeset{} = Content.change_solution(solution)
    end
  end

  describe "lessons" do
    alias Resolvinator.Content.Lesson

    import Resolvinator.ContentFixtures

    @invalid_attrs %{name: nil, desc: nil, upvotes: nil, downvotes: nil}

    test "list_lessons/0 returns all lessons" do
      lesson = lesson_fixture()
      assert Content.list_lessons() == [lesson]
    end

    test "get_lesson!/1 returns the lesson with given id" do
      lesson = lesson_fixture()
      assert Content.get_lesson!(lesson.id) == lesson
    end

    test "create_lesson/1 with valid data creates a lesson" do
      valid_attrs = %{name: "some name", desc: "some desc", upvotes: 42, downvotes: 42}

      assert {:ok, %Lesson{} = lesson} = Content.create_lesson(valid_attrs)
      assert lesson.name == "some name"
      assert lesson.desc == "some desc"
      assert lesson.upvotes == 42
      assert lesson.downvotes == 42
    end

    test "create_lesson/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_lesson(@invalid_attrs)
    end

    test "update_lesson/2 with valid data updates the lesson" do
      lesson = lesson_fixture()
      update_attrs = %{name: "some updated name", desc: "some updated desc", upvotes: 43, downvotes: 43}

      assert {:ok, %Lesson{} = lesson} = Content.update_lesson(lesson, update_attrs)
      assert lesson.name == "some updated name"
      assert lesson.desc == "some updated desc"
      assert lesson.upvotes == 43
      assert lesson.downvotes == 43
    end

    test "update_lesson/2 with invalid data returns error changeset" do
      lesson = lesson_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_lesson(lesson, @invalid_attrs)
      assert lesson == Content.get_lesson!(lesson.id)
    end

    test "delete_lesson/1 deletes the lesson" do
      lesson = lesson_fixture()
      assert {:ok, %Lesson{}} = Content.delete_lesson(lesson)
      assert_raise Ecto.NoResultsError, fn -> Content.get_lesson!(lesson.id) end
    end

    test "change_lesson/1 returns a lesson changeset" do
      lesson = lesson_fixture()
      assert %Ecto.Changeset{} = Content.change_lesson(lesson)
    end
  end
end
