defmodule Resolvinator.Content.Solution do
  import Ecto.Changeset

  use Resolvinator.Content.ContentBehavior,
    type_name: :solution,
    table_name: "solutions",
    relationship_table: "solution_relationships",
    description_table: "solution_descriptions",
    relationship_keys: [solution_id: :id, related_solution_id: :id],
    description_keys: [solution_id: :id, description_id: :id],
    additional_schema: [
      fields: [
        title: :string,
        content: :string,
        votes: {:integer, default: 0}
      ],
      relationships: [
        belongs_to: [
          problem: [
            module: Resolvinator.Content.Problem
          ],
          user: [
            module: Resolvinator.Acts.User
          ]
        ],
        many_to_many: [
          users_with_solution: [
            module: Resolvinator.Acts.User,
            join_through: "user_solutions",
            join_keys: [solution_id: :id, user_id: :id],
            on_replace: :delete
          ]
        ]
      ]
    ]

  def changeset(solution, attrs) do
    solution
    |> cast(attrs, [:title, :content, :status])
    |> validate_required([:title, :content])
  end

  def users_with_solution_changeset(solution, users) do
    solution
    |> cast(%{}, [])
    |> put_assoc(:users_with_solution, users)
  end
end
