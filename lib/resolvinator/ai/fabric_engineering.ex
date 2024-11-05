defmodule Resolvinator.AI.FabricEngineering do
  @moduledoc """
  Integrates with Microsoft Fabric for AI-assisted data engineering tasks.
  """

  alias Resolvinator.AI.FabricClient

  @doc """
  Analyzes schema structure and suggests optimizations using Fabric's AI capabilities.
  """
  def analyze_schema(schema_module) do
    schema_definition = extract_schema_definition(schema_module)

    FabricClient.analyze_schema(%{
      schema: schema_definition,
      analysis_type: "optimization",
      include_suggestions: true
    })
  end

  @doc """
  Suggests data types and validations based on field names and sample data.
  """
  def suggest_data_types(field_names, sample_data) do
    FabricClient.suggest_types(%{
      fields: field_names,
      samples: sample_data,
      context: "elixir_ecto"
    })
  end

  @doc """
  Generates schema validation rules using AI analysis.
  """
  def generate_validations(schema_module) do
    schema_definition = extract_schema_definition(schema_module)

    FabricClient.generate_validations(%{
      schema: schema_definition,
      framework: "ecto",
      include_documentation: true
    })
  end

  # Private helpers
  defp extract_schema_definition(module) do
    # Extract schema information using reflection
    module.__schema__(:fields)
    |> Enum.map(fn field ->
      {field, module.__schema__(:type, field)}
    end)
    |> Enum.into(%{})
  end
end
