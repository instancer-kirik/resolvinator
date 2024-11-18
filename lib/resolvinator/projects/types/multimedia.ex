defmodule Resolvinator.Projects.Types.Multimedia do
  @behaviour Resolvinator.Projects.ProjectType

  @impl true
  def validate_settings(settings) do
    with true <- has_valid_multimedia_settings?(settings),
         true <- has_valid_metadata?(settings) do
      :ok
    else
      false -> {:error, "Invalid multimedia project settings"}
    end
  end

  @impl true
  def default_settings do
    %{
      "metadata" => %{
        "domain" => "multimedia",
        "target_audience" => nil,
        "content_type" => nil,  # presentation, album, video, etc.
        "distribution_channels" => [],
        "language" => nil,
        "genre" => nil,
        "tags" => []
      },
      "multimedia" => %{
        "format" => %{
          "primary_format" => nil,  # pptx, mp3, mp4, etc.
          "export_formats" => [],
          "quality_settings" => %{
            "resolution" => nil,
            "bitrate" => nil,
            "compression" => nil
          }
        },
        "content" => %{
          "sections" => [],  # slides, tracks, scenes
          "assets" => %{
            "images" => [],
            "audio" => [],
            "video" => [],
            "fonts" => [],
            "templates" => []
          },
          "duration" => nil,
          "total_size" => nil
        },
        "collaboration" => %{
          "contributors" => [],
          "roles" => %{},
          "review_process" => nil
        },
        "production" => %{
          "tools" => [],
          "workflow_stages" => [],
          "milestones" => []
        },
        "distribution" => %{
          "platforms" => [],
          "release_strategy" => nil,
          "licensing" => nil,
          "drm_settings" => %{}
        }
      },
      "quality_metrics" => %{
        "technical_quality" => %{
          "min_resolution" => nil,
          "min_bitrate" => nil,
          "format_compliance" => []
        },
        "content_quality" => %{
          "review_criteria" => [],
          "accessibility_requirements" => [],
          "localization_needs" => []
        },
        "performance_targets" => %{
          "load_time" => nil,
          "streaming_quality" => nil,
          "compatibility" => []
        }
      },
      "integration" => %{
        "external_services" => %{},
        "api_connections" => %{},
        "storage_locations" => %{
          "primary" => nil,
          "backup" => nil,
          "cdn" => nil
        }
      }
    }
  end

  @impl true
  def required_fields do
    [:name, :description, :risk_appetite, :creator_id, :start_date]
  end

  # Private validation functions
  defp has_valid_multimedia_settings?(%{"multimedia" => multimedia}) when is_map(multimedia), do: true
  defp has_valid_multimedia_settings?(_), do: false

  defp has_valid_metadata?(%{"metadata" => metadata}) when is_map(metadata), do: true
  defp has_valid_metadata?(_), do: false
end
