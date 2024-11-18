defmodule Resolvinator.Projects.Types.Research do
	@behaviour Resolvinator.Projects.ProjectType

	@impl true
	def validate_settings(settings) do
		with true <- has_valid_research_settings?(settings),
				 true <- has_valid_metadata?(settings) do
			:ok
		else
			false -> {:error, "Invalid research project settings"}
		end
	end

	@impl true
	def default_settings do
		%{
			"metadata" => %{
				"domain" => "research",
				"target_audience" => nil,
				"keywords" => [],
				"categories" => []
			},
			"research" => %{
				"methodology" => nil,
				"data_collection_methods" => [],
				"ethical_considerations" => [],
				"research_timeline" => %{
					"literature_review" => nil,
					"data_collection" => nil,
					"analysis" => nil,
					"publication" => nil
				}
			},
			"quality_metrics" => %{
				"peer_review_required" => true,
				"minimum_sample_size" => nil
			}
		}
	end

	@impl true
	def required_fields do
		[:name, :description, :risk_appetite, :creator_id, :target_date]
	end

	# Private validation functions
	defp has_valid_research_settings?(%{"research" => research}) when is_map(research), do: true
	defp has_valid_research_settings?(_), do: false

	defp has_valid_metadata?(%{"metadata" => metadata}) when is_map(metadata), do: true
	defp has_valid_metadata?(_), do: false
end