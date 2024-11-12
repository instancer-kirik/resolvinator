defmodule Resolvinator.Content.RiskCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "risk_categories" do
    field :name, :string
    field :desc, :string
    belongs_to :creator, Resolvinator.Accounts.User
    belongs_to :project, Resolvinator.Projects.Project

    timestamps()
  end

  def changeset(risk_category, attrs) do
    risk_category
    |> cast(attrs, [:name, :desc, :creator_id, :project_id])
    |> validate_required([:name, :desc, :creator_id, :project_id])
  end
end 