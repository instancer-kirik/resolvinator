defmodule Resolvinator.Risks.RiskBehavior do
  defmacro __using__(opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      @priority_values ~w(low medium high critical)
      @status_values ~w(identified analyzing mitigating resolved closed)
      @probability_values ~w(rare unlikely possible likely certain)
      @impact_values ~w(negligible minor moderate major severe)

      schema unquote(opts[:table_name] || raise "table_name is required") do
        field :name, :string
        field :description, :string
        field :probability, :string
        field :impact, :string
        field :priority, :string
        field :status, :string
        field :mitigation_status, :string
        field :detection_date, :date
        field :review_date, :date
        field :visibility, :string, default: "public"
        field :metadata, :map, default: %{}

        # Core relationships
        belongs_to :creator, Resolvinator.Accounts.User
        belongs_to :project, Resolvinator.Projects.Project
        belongs_to :risk_category, Resolvinator.Risks.Category

        # Risk relationships
        many_to_many :related_risks, __MODULE__,
          join_through: unquote(opts[:relationship_table]),
          join_keys: unquote(opts[:relationship_keys])

        # Impact and mitigation tracking
        has_many :impacts, Resolvinator.Risks.Impact
        has_many :mitigations, Resolvinator.Risks.Mitigation

        timestamps(type: :utc_datetime)
      end

      def changeset(risk, attrs) do
        risk
        |> cast(attrs, [
          :name, :description, :probability, :impact, :priority,
          :status, :mitigation_status, :detection_date,
          :review_date, :creator_id, :project_id, :risk_category_id,
          :visibility, :metadata
        ])
        |> validate_required([:name, :description, :probability, :impact,
                            :status, :creator_id, :project_id])
        |> validate_inclusion(:probability, @probability_values)
        |> validate_inclusion(:impact, @impact_values)
        |> validate_inclusion(:priority, @priority_values)
        |> validate_inclusion(:status, @status_values)
        |> validate_inclusion(:visibility, ~w(public private hidden))
        |> calculate_priority()
        |> foreign_key_constraint(:creator_id)
        |> foreign_key_constraint(:project_id)
        |> foreign_key_constraint(:risk_category_id)
      end

      # Query helpers
      def visible_to(query, nil), do: where(query, [r], r.visibility == "public")
      def visible_to(query, %{id: user_id, is_admin: true}), do: query
      def visible_to(query, %{id: user_id}) do
        where(query, [r], r.visibility == "public" or
                         (r.visibility == "private" and r.creator_id == ^user_id))
      end

      defoverridable [changeset: 2]
    end
  end
end 