defmodule ResolvinatorWeb.API.ProjectJSON do
  def data(project, _opts \\ []) do
    %{
      id: project.id,
      type: "project",
      attributes: %{
        name: project.name,
        description: project.description,
        status: project.status,
        inserted_at: project.inserted_at,
        updated_at: project.updated_at
      }
    }
  end
end 