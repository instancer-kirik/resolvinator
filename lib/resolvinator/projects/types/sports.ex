defmodule Resolvinator.Projects.Types.Sports do
  @behaviour Resolvinator.Projects.ProjectType

  @impl true
  def validate_settings(settings) do
    with true <- has_valid_sports_settings?(settings),
         true <- has_valid_metadata?(settings) do
      :ok
    else
      false -> {:error, "Invalid sports project settings"}
    end
  end

  @impl true
  def default_settings do
    %{
      "metadata" => %{
        "domain" => "sports",
        "sport_type" => nil,  # motorsport, football, etc.
        "competition_level" => nil,  # amateur, professional, etc.
        "season" => nil,
        "governing_bodies" => [], # IFFA, FIFA, etc.
        "stadiums_n_tracks" => nil,
        "region" => nil
      },
      "sports" => %{
        "competition" => %{
          "format" => nil,  # league, tournament, series
          "divisions" => [],
          "schedule" => %{
            "events" => [],
            "practice_sessions" => [],
            "qualifiers" => [],
            "main_events" => []
          },
          "scoring_system" => %{
            "points_structure" => %{},
            "tie_breakers" => [],
            "penalties" => []
          }
        },
        "environment" => %{
          "weather_requirements" => [],  # dry, wet, snow conditions
          "surface_types" => [],        # tarmac, gravel, mixed
          "altitude_considerations" => nil,
          "lighting_conditions" => [],   # day, night, artificial
          "temperature_ranges" => %{
            "min" => nil,
            "optimal" => nil,
            "max" => nil
          },
          "track_conditions" => %{
            "surface_preparation" => [],
            "maintenance_schedule" => [],
            "safety_features" => []
          }
        },
        "equipment" => %{
          "vehicles" => %{
            "categories" => [],         # car classes, weight classes
            "specifications" => %{},
            "maintenance_schedule" => [],
            "spare_parts_inventory" => [],
            "technical_regulations" => [],
            "homologation_requirements" => []
          },
          "safety_gear" => %{
            "required_equipment" => [],
            "certification_requirements" => [],
            "inspection_schedule" => [],
            "replacement_criteria" => []
          },
          "measurement_tools" => %{
            "timing_systems" => [],
            "telemetry_devices" => [],
            "diagnostic_equipment" => [],
            "calibration_schedule" => []
          }
        },
        "participant_management" => %{
          "registration" => %{
            "eligibility_criteria" => [],
            "documentation_required" => [],
            "entry_fees" => %{},
            "deadlines" => %{}
          },
          "classifications" => %{
            "age_groups" => [],
            "skill_levels" => [],
            "weight_classes" => [],
            "vehicle_classes" => []
          },
          "licenses" => %{
            "types" => [],
            "requirements" => %{},
            "validity_periods" => %{},
            "renewal_process" => []
          },
          "rankings" => %{
            "point_systems" => [],
            "progression_criteria" => [],
            "historical_data" => %{},
            "championship_standings" => []
          }
        },
        "operations" => %{
          "pre_event" => %{
            "permits_required" => [],
            "setup_checklist" => [],
            "inspection_requirements" => [],
            "briefing_schedule" => []
          },
          "during_event" => %{
            "emergency_procedures" => [],
            "communication_channels" => [],
            "incident_response_plans" => [],
            "race_control_protocols" => []
          },
          "post_event" => %{
            "cleanup_requirements" => [],
            "reporting_obligations" => [],
            "feedback_collection" => [],
            "results_verification" => []
          },
          "safety" => %{
            "medical_facilities" => [],
            "evacuation_plans" => [],
            "safety_car_procedures" => [],
            "flag_protocols" => []
          }
        },
        "financials" => %{
          "revenue_streams" => %{
            "ticket_sales" => %{},
            "sponsorships" => %{},
            "merchandise" => %{},
            "broadcasting_rights" => %{},
            "hospitality_packages" => %{}
          },
          "expenses" => %{
            "venue_costs" => %{},
            "equipment_maintenance" => %{},
            "staff_compensation" => %{},
            "insurance_premiums" => %{},
            "marketing_budget" => %{}
          },
          "prize_money" => %{
            "distribution_structure" => %{},
            "bonus_criteria" => [],
            "payment_schedule" => [],
            "contingency_fund" => %{}
          }
        },
        "compliance" => %{
          "insurance" => %{
            "required_coverage" => [],
            "policy_details" => %{},
            "claim_procedures" => [],
            "liability_limits" => %{}
          },
          "waivers" => %{
            "participant_waivers" => [],
            "media_releases" => [],
            "liability_forms" => [],
            "medical_declarations" => []
          },
          "permits" => %{
            "venue_permits" => [],
            "event_licenses" => [],
            "environmental_clearances" => [],
            "safety_certifications" => []
          },
          "regulations" => %{
            "technical_rules" => [],
            "sporting_regulations" => [],
            "environmental_standards" => [],
            "noise_restrictions" => []
          }
        },
        "training" => %{
          "programs" => %{
            "practice_sessions" => [],
            "coaching_resources" => [],
            "skill_development" => [],
            "safety_training" => []
          },
          "facilities" => %{
            "training_venues" => [],
            "equipment_availability" => %{},
            "scheduling" => [],
            "maintenance_status" => %{}
          },
          "performance_tracking" => %{
            "metrics" => [],
            "assessment_criteria" => [],
            "progress_reports" => [],
            "benchmark_data" => %{}
          }
        },
        "community" => %{
          "fan_clubs" => %{
            "official_groups" => [],
            "membership_programs" => [],
            "benefits" => [],
            "events_calendar" => []
          },
          "social_media" => %{
            "platforms" => [],
            "content_calendar" => [],
            "engagement_metrics" => [],
            "response_guidelines" => []
          },
          "events" => %{
            "fan_meetups" => [],
            "community_outreach" => [],
            "special_promotions" => [],
            "charitable_initiatives" => []
          }
        }
      },
      "quality_metrics" => %{
        "performance" => %{
          "timing_accuracy" => nil,
          "equipment_reliability" => nil,
          "safety_compliance" => nil,
          "incident_rate" => nil
        },
        "event_quality" => %{
          "participant_satisfaction" => nil,
          "spectator_experience" => nil,
          "broadcast_quality" => nil,
          "venue_standards" => nil
        },
        "compliance" => %{
          "rule_adherence" => nil,
          "safety_standards" => nil,
          "environmental_impact" => nil,
          "noise_levels" => nil
        }
      },
      "media" => %{
        "coverage" => %{
          "broadcast_partners" => [],
          "streaming_platforms" => [],
          "social_media" => [],
          "press_coverage" => []
        },
        "content" => %{
          "live_feeds" => [],
          "highlights" => [],
          "analysis" => [],
          "interviews" => [],
          "documentaries" => []
        },
        "statistics" => %{
          "live_timing" => %{},
          "historical_data" => %{},
          "performance_metrics" => %{},
          "championship_stats" => %{}
        }
      },
      "sponsorship" => %{
        "partners" => %{
          "title_sponsors" => [],
          "technical_partners" => [],
          "suppliers" => [],
          "media_partners" => []
        },
        "agreements" => %{
          "contracts" => [],
          "obligations" => [],
          "benefits" => [],
          "performance_clauses" => []
        },
        "activation" => %{
          "branding" => [],
          "promotions" => [],
          "hospitality" => [],
          "digital_presence" => []
        }
      }
    }
  end

  @impl true
  def required_fields do
    [:name, :description, :risk_appetite, :creator_id, :start_date]
  end

  # Private validation functions
  defp has_valid_sports_settings?(%{"sports" => sports}) when is_map(sports), do: true
  defp has_valid_sports_settings?(_), do: false

  defp has_valid_metadata?(%{"metadata" => metadata}) when is_map(metadata), do: true
  defp has_valid_metadata?(_), do: false
end
