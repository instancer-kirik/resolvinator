defmodule Resolvinator.Projects.Types.Analytics do
  @behaviour Resolvinator.Projects.ProjectType

  @impl true
  def validate_settings(settings) do
    with true <- has_valid_analytics_settings?(settings),
         true <- has_valid_metadata?(settings) do
      :ok
    else
      false -> {:error, "Invalid analytics project settings"}
    end
  end

  @impl true
  def default_settings do
    %{
      "metadata" => %{
        "domain" => "analytics",
        "business_unit" => nil,
        "data_domains" => [],
        "stakeholders" => [],
        "compliance_requirements" => []
      },
      "analytics" => %{
        "data_sources" => %{
          "primary" => [],
          "secondary" => [],
          "external" => [],
          "refresh_frequency" => %{}
        },
        "data_model" => %{
          "entities" => [],
          "relationships" => [],
          "metrics" => [],
          "dimensions" => [],
          "hierarchies" => []
        },
        "processing" => %{
          "etl_processes" => [],
          "transformations" => [],
          "data_quality_rules" => [],
          "scheduling" => %{
            "refresh_schedule" => nil,
            "dependencies" => [],
            "priority" => nil
          }
        },
        "visualization" => %{
          "dashboards" => [],
          "reports" => [],
          "chart_types" => [],
          "interactivity" => %{
            "drill_downs" => [],
            "filters" => [],
            "parameters" => []
          }
        },
        "security" => %{
          "access_levels" => [],
          "row_level_security" => %{},
          "data_masking" => [],
          "audit_settings" => %{}
        }
      },
      "quality_metrics" => %{
        "data_quality" => %{
          "accuracy" => nil,
          "completeness" => nil,
          "timeliness" => nil,
          "consistency" => nil
        },
        "performance" => %{
          "query_response_time" => nil,
          "refresh_duration" => nil,
          "concurrent_users" => nil
        },
        "user_satisfaction" => %{
          "usability_score" => nil,
          "adoption_rate" => nil,
          "feedback_metrics" => []
        }
      },
      "integration" => %{
        "bi_tools" => %{},
        "data_warehouses" => %{},
        "api_connections" => %{},
        "export_formats" => [],
        "notification_services" => %{}
      },
      "governance" => %{
        "data_retention" => %{
          "policies" => [],
          "archive_rules" => [],
          "cleanup_procedures" => []
        },
        "documentation" => %{
          "data_dictionary" => nil,
          "business_glossary" => nil,
          "technical_specs" => nil
        },
        "compliance" => %{
          "gdpr" => %{},
          "hipaa" => %{},
          "sox" => %{},
          "custom" => %{}
        }
      }
    }
  end

  @impl true
  def required_fields do
    [:name, :description, :risk_appetite, :creator_id, :start_date]
  end

  # Private validation functions
  defp has_valid_analytics_settings?(%{"analytics" => analytics}) when is_map(analytics), do: true
  defp has_valid_analytics_settings?(_), do: false

  defp has_valid_metadata?(%{"metadata" => metadata}) when is_map(metadata), do: true
  defp has_valid_metadata?(_), do: false
end
