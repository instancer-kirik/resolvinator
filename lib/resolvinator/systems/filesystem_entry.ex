defmodule Resolvinator.Systems.FilesystemEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @entry_types ~w(file directory symlink)
  
  schema "filesystem_entries" do
    field :path, :string
    field :entry_type, :string
    field :size, :integer
    field :permissions, :string
    field :owner, :string
    field :group, :string
    field :last_accessed, :utc_datetime
    field :last_modified, :utc_datetime
    field :checksum, :string
    field :metadata, :map, default: %{}

    belongs_to :system, Resolvinator.Systems.System
    belongs_to :creator, VES.Accounts.User, type: :binary_id
    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :path, :entry_type, :size, :permissions,
      :owner, :group, :last_accessed, :last_modified,
      :checksum, :metadata, :system_id, :creator_id, :parent_id
    ])
    |> validate_required([
      :path, :entry_type, :system_id
    ])
    |> validate_inclusion(:entry_type, @entry_types)
    |> validate_path()
    |> foreign_key_constraint(:system_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:parent_id)
  end

  defp validate_path(changeset) do
    case get_field(changeset, :path) do
      nil -> changeset
      path ->
        if String.starts_with?(path, "/") do
          changeset
        else
          add_error(changeset, :path, "must be an absolute path")
        end
    end
  end
end 