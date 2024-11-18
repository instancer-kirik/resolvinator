defmodule Resolvinator.Projects.Types.Marketing do
	@behaviour Resolvinator.Projects.ProjectType

	@impl true
	def validate_settings(settings) do
		with true <- has_valid_campaign_settings?(settings),
				 true <- has_valid_metadata?(settings) do
			:ok
		else
			false -> {:error, "Invalid marketing project settings"}
		end
	end

	@impl true
	def default_settings do
		%{
			"metadata" => %{
				"domain" => "marketing",
				"target_audience" => nil,
				"market_segment" => nil,
				"campaign_type" => nil,
				"channels" => []
			},
			"campaign" => %{
				"objectives" => [],
				"kpis" => [],
				"budget" => %{
					"total" => nil,
					"allocation" => %{}
				},
				"timeline" => %{
					"planning" => nil,
					"execution" => nil,
					"evaluation" => nil
				},
				"content_strategy" => %{
					"message" => nil,
					"content_types" => [],
					"distribution_channels" => []
				}
			},
			"quality_metrics" => %{
				"engagement_rate" => nil,
				"conversion_target" => nil,
				"roi_target" => nil
			}
		}
	end

	@impl true
	def required_fields do
		[:name, :description, :risk_appetite, :creator_id, :target_date, :start_date]
	end

	# Private validation functions
	defp has_valid_campaign_settings?(%{"campaign" => campaign}) when is_map(campaign), do: true
	defp has_valid_campaign_settings?(_), do: false

	defp has_valid_metadata?(%{"metadata" => metadata}) when is_map(metadata), do: true
	defp has_valid_metadata?(_), do: false
end