defmodule Resolvinator.Scheduling.UserSchedulingPreferencesColorPalette do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_scheduling_preferences_color_palettes" do
    field :purpose, :string

    belongs_to :user_scheduling_preference, Resolvinator.Scheduling.UserPreferences
    belongs_to :user_color_palette, TimeTracker.Colors.UserColorPalette

    timestamps()
  end

  @required_fields [:purpose, :user_scheduling_preference_id, :user_color_palette_id]
  @valid_purposes ["block_types", "energy_levels", "breaks"]

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:purpose, @valid_purposes)
    |> foreign_key_constraint(:user_scheduling_preference_id)
    |> foreign_key_constraint(:user_color_palette_id)
    |> unique_constraint([:user_scheduling_preference_id, :purpose],
      name: :user_scheduling_preferences_color_palettes_user_scheduling_prefere_purpose_index)
  end
end
