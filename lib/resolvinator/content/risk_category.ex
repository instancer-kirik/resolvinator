defmodule Resolvinator.Content.RiskCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "risk_categories" do
    field :name, :string
    field :description, :string
    belongs_to :creator, Resolvinator.Accounts.User
    belongs_to :project, Resolvinator.Projects.Project

    timestamps()
  end

  def changeset(risk_category, attrs) do
    risk_category
    |> cast(attrs, [:name, :description, :creator_id, :project_id])
    |> validate_required([:name, :description, :creator_id, :project_id])
  end
end 