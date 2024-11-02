defmodule ResolvinatorWeb.API.RequirementJSON do
  def data(requirement, _opts \\ []) do
    %{
      id: requirement.id,
      type: "requirement",
      attributes: %{
        name: requirement.name,
        description: requirement.description,
        status: requirement.status,
        priority: requirement.priority,
        inserted_at: requirement.inserted_at,
        updated_at: requirement.updated_at
      }
    }
  end
end 