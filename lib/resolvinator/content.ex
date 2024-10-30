defmodule Resolvinator.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo
  alias Resolvinator.Content.{
    Problem, Solution, Advantage, Lesson, Description,
    UserHiddenDescription, ProblemDescription, SolutionDescription, LessonDescription, AdvantageDescription
  }

  def get_associable(type, id) do
    case Repo.get_by(schema_for_type(type), id: id) do
      nil -> {:error, :not_found}
      entity -> {:ok, entity}
    end
  end

  def get_associable!("problem", id, user_id), do: get_problem_with_visible_descriptions!(id, user_id)
  def get_associable!("solution", id, user_id), do: get_solution_with_visible_descriptions!(id, user_id)
  def get_associable!("advantage", id, user_id), do: get_advantage_with_visible_descriptions!(id, user_id)
  def get_associable!("lesson", id, user_id), do: get_lesson_with_visible_descriptions!(id, user_id)
  def get_associable!("description", id, _user_id), do: Repo.get!(Description, id)
  def get_associable!(_, _, _), do: raise "Invalid associable type"

  def get_problem(id), do: Repo.get!(Problem, id)
  def get_solution(id), do: Repo.get!(Solution, id)
  def get_advantage(id), do: Repo.get!(Advantage, id)
  def get_lesson(id), do: Repo.get!(Lesson, id)
  def get_description(id), do: Repo.get!(Description, id)
  def get_description!(id), do: Repo.get!(Description, id)

  def search_problems(query) do
    search_query = "%#{query}%"
    Problem
    |> order_by(asc: :name)
    |> where([p], ilike(p.name, ^search_query))
    |> limit(5)
    |> Repo.all()
    |> Enum.map(&{&1.name, &1.id, "problem"})
  end

  def search_solutions(query) do
    search_query = "%#{query}%"
    Solution
    |> order_by(asc: :name)
    |> where([s], ilike(s.name, ^search_query))
    |> limit(5)
    |> Repo.all()
    |> Enum.map(&{&1.name, &1.id, "solution"})
  end

  def search_advantages(query) do
    search_query = "%#{query}%"
    Advantage
    |> order_by(asc: :name)
    |> where([a], ilike(a.name, ^search_query))
    |> limit(5)
    |> Repo.all()
    |> Enum.map(&{&1.name, &1.id, "advantage"})
  end

  def search_lessons(query) do
    search_query = "%#{query}%"
    Lesson
    |> order_by(asc: :name)
    |> where([l], ilike(l.name, ^search_query))
    |> limit(5)
    |> Repo.all()
    |> Enum.map(&{&1.name, &1.id, "lesson"})
  end

  def search_descriptions(query, user_id) do
    search_query = "%#{query}%"
    hidden_description_ids = get_hidden_description_ids(user_id)

    Description
    |> order_by(asc: :text)
    |> where([d], ilike(d.text, ^search_query) and d.id not in ^hidden_description_ids)
    |> limit(5)
    |> Repo.all()
    |> Enum.map(&{&1.text, &1.id, "description"})
  end

  def searchAll(query, user_id) do
    problems = search_problems(query)
    solutions = search_solutions(query)
    advantages = search_advantages(query)
    lessons = search_lessons(query)
    descriptions = search_descriptions(query, user_id)
    problems ++ solutions ++ advantages ++ lessons ++ descriptions
  end

  def report_content(item) do
    item
    |> Ecto.Changeset.change(%{status: "reported"})
    |> Repo.update()
  end

  def approve_content(item) do
    item
    |> Ecto.Changeset.change(%{status: "approved"})
    |> Repo.update()
  end

  def reject_content(item, reason \\ "No reason provided") do
    item
    |> Ecto.Changeset.change(%{status: "rejected", rejection_reason: reason})
    |> Repo.update()
  end

  def list_reported_content(schema) do
    Repo.all(from(item in schema, where: item.status == "reported"))
  end

  def list_problems, do: Repo.all(Problem)

  def list_problems(user_id) do
    hidden_description_ids = get_hidden_description_ids(user_id)
    problems_query =
      from g in Problem,
        left_join: d in assoc(g, :descriptions),
        preload: [descriptions: d]

    problems = Repo.all(problems_query)
    Enum.map(problems, fn problem ->
      filtered_descriptions = Enum.reject(problem.descriptions, &(&1.id in hidden_description_ids))
      %{problem | descriptions: filtered_descriptions}
    end)
  end

  def list_solutions(user_id) do
    hidden_description_ids = get_hidden_description_ids(user_id)
    solutions_query =
      from g in Solution,
        left_join: d in assoc(g, :descriptions),
        preload: [descriptions: d]

    solutions = Repo.all(solutions_query)
    Enum.map(solutions, fn solution ->
      filtered_descriptions = Enum.reject(solution.descriptions, &(&1.id in hidden_description_ids))
      %{solution | descriptions: filtered_descriptions}
    end)
  end

  def list_lessons(user_id) do
    hidden_description_ids = get_hidden_description_ids(user_id)
    lessons_query =
      from g in Lesson,
        left_join: d in assoc(g, :descriptions),
        preload: [descriptions: d]

    lessons = Repo.all(lessons_query)
    Enum.map(lessons, fn lesson ->
      filtered_descriptions = Enum.reject(lesson.descriptions, &(&1.id in hidden_description_ids))
      %{lesson | descriptions: filtered_descriptions}
    end)
  end

  def list_advantages(user_id) do
    hidden_description_ids = get_hidden_description_ids(user_id)
    advantages_query =
      from g in Advantage,
        left_join: d in assoc(g, :descriptions),
        preload: [descriptions: d]

    advantages = Repo.all(advantages_query)
    Enum.map(advantages, fn advantage ->
      filtered_descriptions = Enum.reject(advantage.descriptions, &(&1.id in hidden_description_ids))
      %{advantage | descriptions: filtered_descriptions}
    end)
  end

  def get_problem_with_visible_descriptions!(problem_id, user_id) do
    problem = Repo.get!(Problem, problem_id)
    |> Repo.preload([:related_problems, :lessons, :advantages, :solutions, :descriptions])

    hidden_description_ids = get_hidden_description_ids(user_id)
    filtered_descriptions = Enum.reject(problem.descriptions, &(&1.id in hidden_description_ids))
    %{problem | descriptions: filtered_descriptions}
  end

  def get_solution_with_visible_descriptions!(solution_id, user_id) do
    solution = Repo.get!(Solution, solution_id)
    |> Repo.preload([:related_solutions, :problems, :lessons, :advantages, :descriptions])

    hidden_description_ids = get_hidden_description_ids(user_id)
    filtered_descriptions = Enum.reject(solution.descriptions, &(&1.id in hidden_description_ids))
    %{solution | descriptions: filtered_descriptions}
  end

  def get_advantage_with_visible_descriptions!(advantage_id, user_id) do
    advantage = Repo.get!(Advantage, advantage_id)
    |> Repo.preload([:related_advantages, :problems, :solutions, :lessons, :descriptions])

    hidden_description_ids = get_hidden_description_ids(user_id)
    filtered_descriptions = Enum.reject(advantage.descriptions, &(&1.id in hidden_description_ids))
    %{advantage | descriptions: filtered_descriptions}
  end

  def get_lesson_with_visible_descriptions!(lesson_id, user_id) do
    lesson = Repo.get!(Lesson, lesson_id)
    |> Repo.preload([:related_lessons, :problems, :solutions, :advantages, :descriptions])

    hidden_description_ids = get_hidden_description_ids(user_id)
    filtered_descriptions = Enum.reject(lesson.descriptions, &(&1.id in hidden_description_ids))
    %{lesson | descriptions: filtered_descriptions}
  end

  def get_hidden_description_ids(user_id) do
    from(uhd in UserHiddenDescription, where: uhd.user_id == ^user_id, select: uhd.description_id)
    |> Repo.all()
  end

  def hide_description(user_id, description_id) do
    %UserHiddenDescription{user_id: user_id, description_id: description_id}
    |> Repo.insert!()
  end

  def unhide_description(user_id, description_id) do
    from(uhd in UserHiddenDescription, where: uhd.user_id == ^user_id and uhd.description_id == ^description_id)
    |> Repo.delete_all()
  end

  def get_problem!(id) do
    Repo.get!(Problem, id)
    |> Repo.preload([:descriptions, :solutions, :lessons, :advantages])
  end

  def create_problem(attrs \\ %{}) do
    %Problem{}
    |> Problem.changeset(attrs)
    |> Repo.insert()
  end

  def update_problem(%Problem{} = problem, attrs) do
    problem
    |> Problem.changeset(attrs)
    |> Repo.update()
  end

  def delete_problem(%Problem{} = problem) do
    Repo.delete(problem)
  end

  def change_problem(%Problem{} = problem, attrs \\ %{}) do
    Problem.changeset(problem, attrs)
  end

  def list_advantages, do: Repo.all(Advantage)

  def get_advantage!(id) do
    Repo.get!(Advantage, id)
    |> Repo.preload([:descriptions, :problems, :solutions, :lessons])
  end

  def create_advantage(attrs \\ %{}) do
    %Advantage{}
    |> Advantage.changeset(attrs)
    |> Repo.insert()
  end

  def update_advantage(%Advantage{} = advantage, attrs) do
    advantage
    |> Advantage.changeset(attrs)
    |> Repo.update()
  end

  def delete_advantage(%Advantage{} = advantage) do
    Repo.delete(advantage)
  end

  def change_advantage(%Advantage{} = advantage, attrs \\ %{}) do
    Advantage.changeset(advantage, attrs)
  end

  def list_solutions, do: Repo.all(Solution)

  def get_solution!(id) do
    Repo.get!(Solution, id)
    |> Repo.preload([:descriptions, :problems])
  end

  def create_solution(attrs \\ %{}) do
    %Solution{}
    |> Solution.changeset(attrs)
    |> Repo.insert()
  end

  def update_solution(%Solution{} = solution, attrs) do
    solution
    |> Solution.changeset(attrs)
    |> Repo.update()
  end

  def delete_solution(%Solution{} = solution) do
    Repo.delete(solution)
  end

  def change_solution(%Solution{} = solution, attrs \\ %{}) do
    Solution.changeset(solution, attrs)
  end

  def list_lessons, do: Repo.all(Lesson)

  def get_lesson!(id) do
    Repo.get!(Lesson, id)
    |> Repo.preload([:descriptions, :problems, :solutions, :advantages])
  end

  def get_lesson_with_associations!(id) do
    lesson = Repo.get!(Lesson, id)
    Repo.preload(lesson, [:problems, :solutions, :advantages])
  end

  def create_lesson(attrs \\ %{}) do
    %Lesson{}
    |> Lesson.changeset(attrs)
    |> Repo.insert()
  end

  def update_lesson(%Lesson{} = lesson, attrs) do
    lesson
    |> Lesson.changeset(attrs)
    |> Repo.update()
  end

  def delete_lesson(%Lesson{} = lesson) do
    Repo.delete(lesson)
  end

  def change_lesson(%Lesson{} = lesson, attrs \\ %{}) do
    Lesson.changeset(lesson, attrs)
  end

  def relate_records(source, target) do
    case {source.__struct__, target.__struct__} do
      {Problem, Problem} -> add_problem_to_problem(source, target)
      {Problem, Solution} -> add_solution_to_problem(source, target)
      {Problem, Advantage} -> add_advantage_to_problem(source, target)
      {Problem, Lesson} -> add_lesson_to_problem(source, target)
      {Problem, Description} -> add_description_to_problem(source, target)

      {Solution, Problem} -> add_problem_to_solution(source, target)
      {Solution, Solution} -> add_solution_to_solution(source, target)
      {Solution, Lesson} -> add_lesson_to_solution(source, target)
      {Solution, Advantage} -> add_advantage_to_solution(source, target)
      {Solution, Description} -> add_description_to_solution(source, target)

      {Lesson, Problem} -> add_problem_to_lesson(source, target)
      {Lesson, Solution} -> add_solution_to_lesson(source, target)
      {Lesson, Lesson} -> add_lesson_to_lesson(source, target)
      {Lesson, Advantage} -> add_advantage_to_lesson(source, target)
      {Lesson, Description} -> add_description_to_lesson(source, target)

      {Advantage, Problem} -> add_problem_to_advantage(source, target)
      {Advantage, Solution} -> add_solution_to_advantage(source, target)
      {Advantage, Lesson} -> add_lesson_to_advantage(source, target)
      {Advantage, Advantage} -> add_advantage_to_advantage(source, target)
      {Advantage, Description} -> add_description_to_advantage(source, target)

      {Description, Problem} -> add_description_to_problem(source, target)
      {Description, Solution} -> add_description_to_solution(source, target)
      {Description, Lesson} -> add_description_to_lesson(source, target)
      {Description, Advantage} -> add_description_to_advantage(source, target)
      {Description, Description} -> {:error, "Description-to-description relationship not supported"}

      _ -> {:error, "Unsupported relationship"}
    end
  end
  defp add_description_to_problem(%Problem{} = problem, %Description{} = description) do
    current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    description_changeset =
      description
      |> Ecto.Changeset.change(descriptionable_id: problem.id, descriptionable_type: "Problem")
      |> Repo.update()

    case description_changeset do
      {:ok, _description} ->
        %ProblemDescription{}
        |> Ecto.Changeset.change(%{
          problem_id: problem.id,
          description_id: description.id,
          inserted_at: current_time,
          updated_at: current_time
        })
        |> Repo.insert()

      {:error, changeset} ->
        {:error, changeset}
    end
  end
  defp add_description_to_advantage(%Advantage{} = advantage, %Description{} = description) do
    current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    description_changeset =
      description
      |> Ecto.Changeset.change(descriptionable_id: advantage.id, descriptionable_type: "Advantage")
      |> Repo.update()

    case description_changeset do
      {:ok, _description} ->
        %AdvantageDescription{}
        |> Ecto.Changeset.change(%{
          advantage_id: advantage.id,
          description_id: description.id,
          inserted_at: current_time,
          updated_at: current_time
        })
        |> Repo.insert()

      {:error, changeset} ->
        {:error, changeset}
    end
  end
  defp add_description_to_lesson(%Lesson{} = lesson, %Description{} = description) do
    current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    description_changeset =
      description
      |> Ecto.Changeset.change(descriptionable_id: lesson.id, descriptionable_type: "Lesson")
      |> Repo.update()

    case description_changeset do
      {:ok, _description} ->
        %LessonDescription{}
        |> Ecto.Changeset.change(%{
          lesson_id: lesson.id,
          description_id: description.id,
          inserted_at: current_time,
          updated_at: current_time
        })
        |> Repo.insert()

      {:error, changeset} ->
        {:error, changeset}
    end
  end
  defp add_description_to_solution(%Solution{} = solution, %Description{} = description) do
    current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    description_changeset =
      description
      |> Ecto.Changeset.change(descriptionable_id: solution.id, descriptionable_type: "Solution")
      |> Repo.update()

    case description_changeset do
      {:ok, _description} ->
        %SolutionDescription{}
        |> Ecto.Changeset.change(%{
          solution_id: solution.id,
          description_id: description.id,
          inserted_at: current_time,
          updated_at: current_time
        })
        |> Repo.insert()

      {:error, changeset} ->
        {:error, changeset}
    end
  end
  defp add_problem_to_problem(%Problem{} = problem, %Problem{} = related_problem) do
    Ecto.Changeset.change(problem)
    |> Ecto.Changeset.put_assoc(:related_problems, [related_problem | problem.related_problems])
    |> Repo.update()
  end

  defp add_solution_to_problem(%Problem{} = problem, %Solution{} = solution) do
    Ecto.Changeset.change(problem)
    |> Ecto.Changeset.put_assoc(:solutions, [solution | problem.solutions])
    |> Repo.update()
  end

  defp add_advantage_to_problem(%Problem{} = problem, %Advantage{} = advantage) do
    Ecto.Changeset.change(problem)
    |> Ecto.Changeset.put_assoc(:advantages, [advantage | problem.advantages])
    |> Repo.update()
  end

  defp add_lesson_to_problem(%Problem{} = problem, %Lesson{} = lesson) do
    Ecto.Changeset.change(problem)
    |> Ecto.Changeset.put_assoc(:lessons, [lesson | problem.lessons])
    |> Repo.update()
  end



  defp add_problem_to_solution(%Solution{} = solution, %Problem{} = problem) do
    Ecto.Changeset.change(solution)
    |> Ecto.Changeset.put_assoc(:problems, [problem | solution.problems])
    |> Repo.update()
  end

  defp add_solution_to_solution(%Solution{} = solution1, %Solution{} = solution2) do
    Ecto.Changeset.change(solution1)
    |> Ecto.Changeset.put_assoc(:related_solutions, [solution2 | solution1.related_solutions])
    |> Repo.update()
  end

  defp add_lesson_to_solution(%Solution{} = solution, %Lesson{} = lesson) do
    Ecto.Changeset.change(solution)
    |> Ecto.Changeset.put_assoc(:lessons, [lesson | solution.lessons])
    |> Repo.update()
  end

  defp add_advantage_to_solution(%Solution{} = solution, %Advantage{} = advantage) do
    Ecto.Changeset.change(solution)
    |> Ecto.Changeset.put_assoc(:advantages, [advantage | solution.advantages])
    |> Repo.update()
  end



  defp add_problem_to_lesson(%Lesson{} = lesson, %Problem{} = problem) do
    Ecto.Changeset.change(lesson)
    |> Ecto.Changeset.put_assoc(:problems, [problem | lesson.problems])
    |> Repo.update()
  end

  defp add_solution_to_lesson(%Lesson{} = lesson, %Solution{} = solution) do
    Ecto.Changeset.change(lesson)
    |> Ecto.Changeset.put_assoc(:solutions, [solution | lesson.solutions])
    |> Repo.update()
  end

  defp add_lesson_to_lesson(%Lesson{} = lesson1, %Lesson{} = lesson2) do
    Ecto.Changeset.change(lesson1)
    |> Ecto.Changeset.put_assoc(:related_lessons, [lesson2 | lesson1.related_lessons])
    |> Repo.update()
  end

  defp add_advantage_to_lesson(%Lesson{} = lesson, %Advantage{} = advantage) do
    Ecto.Changeset.change(lesson)
    |> Ecto.Changeset.put_assoc(:advantages, [advantage | lesson.advantages])
    |> Repo.update()
  end



  defp add_problem_to_advantage(%Advantage{} = advantage, %Problem{} = problem) do
    Ecto.Changeset.change(advantage)
    |> Ecto.Changeset.put_assoc(:problems, [problem | advantage.problems])
    |> Repo.update()
  end

  defp add_solution_to_advantage(%Advantage{} = advantage, %Solution{} = solution) do
    Ecto.Changeset.change(advantage)
    |> Ecto.Changeset.put_assoc(:solutions, [solution | advantage.solutions])
    |> Repo.update()
  end

  defp add_lesson_to_advantage(%Advantage{} = advantage, %Lesson{} = lesson) do
    Ecto.Changeset.change(advantage)
    |> Ecto.Changeset.put_assoc(:lessons, [lesson | advantage.lessons])
    |> Repo.update()
  end

  defp add_advantage_to_advantage(%Advantage{} = advantage1, %Advantage{} = advantage2) do
    Ecto.Changeset.change(advantage1)
    |> Ecto.Changeset.put_assoc(:related_advantages, [advantage2 | advantage1.related_advantages])
    |> Repo.update()
  end


  defp schema_for_type("problem"), do: Problem
  defp schema_for_type("solution"), do: Solution
  defp schema_for_type("advantage"), do: Advantage
  defp schema_for_type("lesson"), do: Lesson
  defp schema_for_type("description"), do: Description
  defp schema_for_type(_), do: nil

  def add_user_using_solution(solution, user) do
    solution
    |> Repo.preload(:users_using_solution)
    |> Solution.users_using_solution_changeset([user | solution.users_using_solution])
    |> Repo.update()
  end

  def update_users_using_solution(solution, users) do
    solution
    |> Solution.users_using_solution_changeset(users)
    |> Repo.update()
  end

  def list_solutions_created_by(user_id) do
    Solution
    |> where([s], s.creator_id == ^user_id)
    |> Repo.all()
  end

  def list_solutions_for_user(user_id) do
    Solution
    |> join(:inner, [s], us in "user_solutions", on: us.solution_id == s.id)
    |> where([s, us], us.user_id == ^user_id)
    |> Repo.all()
  end
end
