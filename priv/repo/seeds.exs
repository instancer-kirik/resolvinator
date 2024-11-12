# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
alias Resolvinator.Repo
alias Resolvinator.Accounts
alias Resolvinator.Content.{Problem, Solution, Advantage, Lesson, Question, Answer, Theorem}
alias Resolvinator.Projects
alias Resolvinator.Risks

# Function to safely run seed operations
defmodule Seeds.Helper do
  def safe_run(description, fun) do
    IO.puts("\nSeeding #{description}...")
    try do
      result = fun.()
      IO.puts("✓ Successfully seeded #{description}")
      result
    rescue
      e ->
        IO.puts("✗ Failed to seed #{description}: #{inspect(e)}")
        IO.puts("Stacktrace:")
        IO.puts(Exception.format_stacktrace(__STACKTRACE__))
        # Continue with other seeds despite this failure
        nil
    end
  end
end

# Create admin user if doesn't exist
admin = Seeds.Helper.safe_run "admin user", fn ->
  case Accounts.get_user_by_email("admin@example.com") do
    nil ->
      {:ok, admin} = Accounts.register_user(%{
        email: "admin@example.com",
        username: "admin",
        password: "adminpass123!",
        is_admin: true
      })
      admin
    existing_admin ->
      existing_admin
  end
end

# Only continue with project creation if we have an admin
if admin do
  # Create initial project if doesn't exist
  project = Seeds.Helper.safe_run "project", fn ->
    case Projects.get_project_by_name("Mathematics Learning Platform") do
      nil ->
        {:ok, project} = Projects.create_project(%{
          name: "Mathematics Learning Platform",
          description: "A platform for learning advanced mathematics concepts",
          status: "active",
          risk_appetite: "cautious",
          creator_id: admin.id(),
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
        })
        project
      existing_project ->
        existing_project
    end
  end

  # Add a guard to check if project creation succeeded
  if project do
    IO.puts("Project created/found successfully: #{project.id}")
  else
    IO.puts("Failed to create/find project")
  end

  # Only continue with risk categories if we have a project
  if project do
    # Create risk categories
    categories = Seeds.Helper.safe_run "risk categories", fn ->
      risk_categories = [
        %{
          name: "Technical",
          description: "Risks related to technical implementation and architecture",
          creator_id: admin.id(),
          project_id: project.id
        },
        %{
          name: "Educational",
          description: "Risks related to learning outcomes and content delivery",
          creator_id: admin.id(),
          project_id: project.id
        }
      ]

      Enum.map(risk_categories, fn category_attrs ->
        case Risks.get_category_by_name(category_attrs.name) do
          nil ->
            {:ok, category} = Risks.create_category(category_attrs)
            category
          existing_category ->
            existing_category
        end
      end)
    end

    # Only continue with risks if we have categories
    if categories do
      # Create risks
      created_risks = Seeds.Helper.safe_run "risks", fn ->
        risks = [
          %{
            name: "Complex Mathematical Concepts",
            description: "Students might struggle with advanced mathematical concepts",
            probability: "likely",
            impact: "moderate",
            status: "identified",
            mitigation_status: "in_progress",
            creator_id: admin.id(),
            project_id: project.id,
            risk_category_id: Enum.at(categories, 1).id,
            detection_date: Date.utc_today(),
            review_date: Date.add(Date.utc_today(), 30),
            metadata: %{
              "affected_areas" => ["learning_outcomes", "student_engagement"],
              "target_grade_level" => "high_school"
            }
          },
          %{
            name: "System Performance",
            description: "System might slow down with multiple concurrent users",
            probability: "possible",
            impact: "major",
            status: "analyzing",
            mitigation_status: "planned",
            creator_id: admin.id(),
            project_id: project.id,
            risk_category_id: Enum.at(categories, 0).id,
            detection_date: Date.utc_today(),
            review_date: Date.add(Date.utc_today(), 14),
            metadata: %{
              "affected_components" => ["database", "web_server"],
              "performance_threshold" => "1000_users"
            }
          }
        ]

        Enum.map(risks, fn risk_attrs ->
          case Risks.get_risk_by_name(risk_attrs.name) do
            nil ->
              {:ok, risk} = Risks.create_risk(risk_attrs)
              risk
            existing_risk ->
              existing_risk
          end
        end)
      end

      # Create impacts if we have risks
      if created_risks do
        Seeds.Helper.safe_run "impacts", fn ->
          Enum.each(Enum.with_index(created_risks), fn {risk, index} ->
            impact_attrs = %{
              description: "Impact #{index + 1} for #{risk.name}",
              area: "educational",
              severity: "medium",
              likelihood: "high",
              estimated_cost: Decimal.new("1000.00"),
              timeframe: "3_months",
              notes: "Regular monitoring required",
              risk_id: risk.id,
              creator_id: admin.id()
            }
            
            {:ok, _impact} = Risks.create_impact(impact_attrs)
          end)
        end
      end
    end
  end

  # Only continue with content creation if we have a project
  if project do
    # Create topics
    _topics = Seeds.Helper.safe_run "topics", fn ->
      topic_attrs = [
        %{
          name: "Mathematics",
          description: "Core mathematical concepts",
          slug: "mathematics",
          category: "core",
          level: "beginner",
          is_featured: true,
          creator_id: admin.id(),
          project_id: project.id
        },
        %{
          name: "Computer Science",
          description: "Computer science fundamentals",
          slug: "computer-science",
          category: "core",
          level: "beginner",
          is_featured: true,
          creator_id: admin.id(),
          project_id: project.id
        }
      ]

      Enum.map(topic_attrs, fn attrs ->
        case Resolvinator.Topics.get_topic_by_slug(attrs.slug) do
          nil -> 
            {:ok, topic} = Resolvinator.Topics.create_topic(attrs)
            topic
          existing_topic -> 
            existing_topic
        end
      end)
    end

    # Create theorems and related content
    Seeds.Helper.safe_run "mathematical content", fn ->
      # Create theorem
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
        creator_id: admin.id(),
        project_id: project.id,
        status: "published"
      })

      # Create question
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
        creator_id: admin.id(),
        project_id: project.id,
        status: "published"
      })

      # Create answer
      {:ok, answer} = Repo.insert(%Answer{
        name: "Geometric Proof of Pythagorean Theorem",
        desc: "A proof using area comparison of squares",
        answer_type: "proof",
        references: ["Euclid's Elements"],
        question_id: question.id,
        creator_id: admin.id(),
        project_id: project.id,
        status: "published"
      })

      # Create problem and solution
      {:ok, problem} = Seeds.Helper.safe_run "problem", fn ->
        # Create problem with all attributes at once
        Repo.insert(%Problem{
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
      end

      {:ok, solution} = Seeds.Helper.safe_run "solution", fn ->
        Repo.insert(%Solution{
          name: "Using the Pythagorean Formula",
          desc: "Apply a² + b² = c² to find the missing side",
          creator_id: admin.id(),
          project_id: project.id,
          status: "published"
        })
      end

      # Create advantage and lesson
      {:ok, advantage} = Repo.insert(%Advantage{
        name: "Quick Triangle Calculations",
        desc: "Enables rapid calculation of unknown sides in right triangles",
        creator_id: admin.id(),
        project_id: project.id,
        status: "published"
      })

      {:ok, lesson} = Repo.insert(%Lesson{
        name: "Introduction to the Pythagorean Theorem",
        desc: "Learn about one of the most fundamental theorems in geometry",
        creator_id: admin.id(),
        project_id: project.id,
        status: "published"
      })

      # Update relationships
      # Link theorem to question
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

      # Add voting and moderation data
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
            reviewed_by: admin.id()
          }
        })
        |> Repo.update!()
      end

      # Return all created content for potential future use
      %{
        theorem: pythagoras,
        question: question,
        answer: answer,
        problem: problem,
        solution: solution,
        advantage: advantage,
        lesson: lesson
      }
    end
  end # end if project
end # end if admin

IO.puts("\nSeed operation completed!") 