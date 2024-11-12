# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
alias Resolvinator.Repo
alias Resolvinator.Accounts
alias Resolvinator.Content.{Problem, Solution, Advantage, Lesson, Question, Answer, Theorem}
alias Resolvinator.Projects

# Create admin user
{:ok, admin} = Resolvinator.Accounts.register_user(%{
  email: "admin@example.com",
  username: "admin",
  password: "adminpass123!",
  is_admin: true
})

IO.puts("Admin user created successfully: #{inspect(admin)}")

# Create initial project
project_params = %{
  name: "Mathematics Learning Platform",
  description: "A platform for learning advanced mathematics concepts",
  status: "active",
  risk_appetite: "cautious",
  creator_id: admin.id,
  settings: %{
    "metadata" => %{
      "domain" => "education",
      "target_audience" => "students",
      "version" => "0.1.0",
      "language" => "python",
      "framework" => "flask",
      "keywords" => ["education", "mathematics", "learning"],
      "categories" => ["education", "stem"],
      "visibility" => "private"
    }
  }
}

IO.puts("Project params: #{inspect(project_params)}")

# Create project and bind it to a variable
{:ok, project} = case Resolvinator.Projects.create_project(project_params) do
  {:ok, project} -> 
    IO.puts("Project created successfully: #{inspect(project)}")
    {:ok, project}
  {:error, changeset} -> 
    IO.puts("Failed to create project. Full changeset: #{inspect(changeset)}")
    raise "Failed to create project"
end

# Now we can use project.id safely
topics = [
  %{
    name: "Mathematics",
    description: "Core mathematical concepts",
    slug: "mathematics",
    category: "core",
    level: "beginner",
    is_featured: true,
    creator_id: admin.id,
    project_id: project.id
  },
  %{
    name: "Computer Science",
    description: "Computer science fundamentals",
    slug: "computer-science",
    category: "core",
    level: "beginner",
    is_featured: true,
    creator_id: admin.id,
    project_id: project.id
  }
]

Enum.each(topics, fn topic_attrs ->
  {:ok, _topic} = Resolvinator.Topics.create_topic(topic_attrs)
end)

# Create some theorems
{:ok, pythagoras} = Repo.insert(%Theorem{
  name: "Pythagorean Theorem",
  desc: "In a right triangle, the square of the hypotenuse equals the sum of squares of the other sides",
  formal_statement: "For a right triangle with sides a, b, and hypotenuse c: a² + b² = c²",
  proof_strategy: "geometric",
  complexity_level: "basic",
  field_of_study: "geometry",
  prerequisites: ["basic algebra", "triangle properties"],
  notation_used: %{
    "a" => "first side",
    "b" => "second side",
    "c" => "hypotenuse"
  },
  creator_id: admin.id,
  project_id: project.id,
  status: "published"
})

# Create some questions
{:ok, question} = Repo.insert(%Question{
  name: "Prove the Pythagorean Theorem",
  desc: "Provide a geometric proof of the Pythagorean Theorem",
  question_type: "technical",
  context: "geometry",
  expected_answer_format: "structured proof",
  difficulty_level: "intermediate",
  subject_area: "geometry",
  requires_proof: true,
  proof_technique_hints: ["area comparison", "similar triangles"],
  creator_id: admin.id,
  project_id: project.id,
  status: "published"
})

# Create some answers
{:ok, answer} = Repo.insert(%Answer{
  name: "Geometric Proof of Pythagorean Theorem",
  desc: "A proof using area comparison of squares",
  answer_type: "proof",
  references: ["Euclid's Elements"],
  question_id: question.id,
  creator_id: admin.id,
  project_id: project.id,
  status: "published"
})

# Create some problems
{:ok, problem} = Repo.insert(%Problem{
  name: "Triangle Side Length Calculation",
  desc: "Calculate the length of a right triangle's hypotenuse",
  creator_id: admin.id,
  project_id: project.id,
  status: "published",
  impacts: [
    %{
      severity: "medium",
      likelihood: "high",
      description: "Common calculation error in engineering"
    }
  ]
})

# Create some solutions
{:ok, solution} = Repo.insert(%Solution{
  name: "Using the Pythagorean Formula",
  desc: "Apply a² + b² = c² to find the missing side",
  creator_id: admin.id,
  project_id: project.id,
  status: "published"
})

# Create some advantages
{:ok, advantage} = Repo.insert(%Advantage{
  name: "Quick Triangle Calculations",
  desc: "Enables rapid calculation of unknown sides in right triangles",
  creator_id: admin.id,
  project_id: project.id,
  status: "published"
})

# Create some lessons
{:ok, lesson} = Repo.insert(%Lesson{
  name: "Introduction to the Pythagorean Theorem",
  desc: "Learn about one of the most fundamental theorems in geometry",
  creator_id: admin.id,
  project_id: project.id,
  status: "published"
})

# Update relationships
Repo.preload(question, [:theorems])
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:theorems, [pythagoras])
|> Repo.update!()

# Link problem to solution
Repo.preload(problem, [:solutions])
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:solutions, [solution])
|> Repo.update!()

# Link lesson to problem and solution
Repo.preload(lesson, [:problems, :solutions])
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:problems, [problem])
|> Ecto.Changeset.put_assoc(:solutions, [solution])
|> Repo.update!()

# Update answer acceptance
Repo.preload(question, [:accepted_answer])
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:accepted_answer, answer)
|> Repo.update!()

# Add some voting and moderation data
for content <- [pythagoras, question, answer, problem, solution, advantage, lesson] do
  content
  |> Ecto.Changeset.change(%{
    voting: %{
      upvotes: Enum.random(1..100),
      downvotes: Enum.random(1..20)
    },
    moderation: %{
      status: "approved",
      reviewed_at: DateTime.utc_now(),
      reviewed_by: admin.id
    }
  })
  |> Repo.update!()
end

IO.puts "Demo data seeded successfully!" 