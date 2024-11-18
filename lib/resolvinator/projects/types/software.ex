defmodule Resolvinator.Projects.Types.Software do
	@behaviour Resolvinator.Projects.ProjectType

	@impl true
	def validate_settings(settings) do
		with true <- has_valid_development_settings?(settings),
				 true <- has_valid_metadata?(settings) do
			:ok
		else
			false -> {:error, "Invalid software project settings"}
		end
	end

	@impl true
	def default_settings do
		%{
			"metadata" => %{
				"domain" => "software",
				"language" => nil,
				"framework" => nil,
				"version" => "0.1.0",
				"repository_url" => nil,
				"dependencies" => %{},
			},
			"development" => %{
				"build_command" => nil,
				"test_command" => nil,
				"file_extensions" => [".ex", ".exs", ".eex"],
				"excluded_dirs" => ["_build", "deps", ".elixir_ls"],
			},
			"quality_metrics" => %{
				"test_coverage_target" => 85,
				"max_complexity" => 10
			}
		}
	end

	@impl true
	def required_fields do
		[:name, :description, :risk_appetite, :creator_id]
	end

	# Private validation functions
	defp has_valid_development_settings?(%{"development" => dev}) when is_map(dev), do: true
	defp has_valid_development_settings?(_), do: false

	defp has_valid_metadata?(%{"metadata" => metadata}) when is_map(metadata), do: true
	defp has_valid_metadata?(_), do: false
end