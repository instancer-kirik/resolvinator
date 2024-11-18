defmodule Resolvinator.Projects.Types.Education do
	@behaviour Resolvinator.Projects.ProjectType

	@impl true
	def validate_settings(settings) do
		with true <- has_valid_education_settings?(settings),
				 true <- has_valid_metadata?(settings) do
			:ok
		else
			false -> {:error, "Invalid education project settings"}
		end
	end

	@impl true
	def default_settings do
		%{
			"metadata" => %{
				"domain" => "education",
				"education_level" => nil,
				"subject_area" => nil,
				"delivery_method" => nil,
				"certification_type" => nil
			},
			"education" => %{
				"curriculum" => %{
					"learning_objectives" => [],
					"modules" => [],
					"assessment_methods" => []
				},
				"resources" => %{
					"materials" => [],
					"tools" => [],
					"references" => []
				},
				"delivery" => %{
					"format" => nil,
					"duration" => nil,
					"schedule" => nil,
					"prerequisites" => []
				}
			},
			"quality_metrics" => %{
				"completion_rate_target" => 80,
				"satisfaction_score_target" => 4.0,
				"knowledge_retention_target" => 75
			}
		}
	end

	@impl true
	def required_fields do
		[:name, :description, :risk_appetite, :creator_id, :start_date]
	end

	# Private validation functions
	defp has_valid_education_settings?(%{"education" => education}) when is_map(education), do: true
	defp has_valid_education_settings?(_), do: false

	defp has_valid_metadata?(%{"metadata" => metadata}) when is_map(metadata), do: true
	defp has_valid_metadata?(_), do: false
end