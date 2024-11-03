defmodule Resolvinator.Risks.Impact do
  use Resolvinator.Risks.ImpactBehavior,
    table_name: "impacts"

  def changeset(impact, attrs) do
    impact
    |> base_changeset(attrs)
  end
end
