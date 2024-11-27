defmodule Resolvinator.Tech.TechItemActivity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tech_item_activities" do
    field :activity_type, :string
    field :description, :string
    field :metadata, :map

    belongs_to :item, Resolvinator.Tech.TechItem
    belongs_to :user, Acts.User, type: :binary_id

    timestamps()
  end

  @required_fields ~w(activity_type description item_id)a
  @optional_fields ~w(metadata user_id)a
  @activity_types ~w(maintenance assignment status_change repair inspection)

  def changeset(tech_item_activity, attrs) do
    tech_item_activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:activity_type, @activity_types)
    |> validate_metadata()
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:user_id)
  end

  defp validate_metadata(changeset) do
    validate_change(changeset, :metadata, fn :metadata, metadata ->
      case validate_map_structure(metadata) do
        :ok -> []
        {:error, reason} -> [metadata: reason]
      end
    end)
  end

  defp validate_map_structure(map) when is_map(map), do: :ok
  defp validate_map_structure(_), do: {:error, "must be a map"}
end
