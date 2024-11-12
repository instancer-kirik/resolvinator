# Risk Management Seeds

# Add at the top of the file
alias Resolvinator.{Repo, Accounts, Projects}

# Create users
{:ok, user1} = Accounts.register_user(%{
  email: "admin@example.com",
  password: "adminpass123!",
  username: "admin",
  is_admin: true
})

{:ok, user2} = Accounts.register_user(%{
  email: "user@example.com",
  password: "userpass123!",
  username: "user"
})

# Create project
{:ok, project1} = Projects.create_project(%{
  name: "Demo Project",
  description: "A demonstration project",
  status: "active",
  creator_id: user1.id
})

# Add current timestamp for relationships
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

# Create Risk Categories with more detailed assessment criteria
risk_categories = [
  %{
    name: "Technical Risk",
    description: "Risks related to technical implementation and architecture",
    color: "#FF4444",
    assessment_criteria: %{
      "probability_factors" => [
        "Technical complexity",
        "Team expertise",
        "Technology maturity",
        "Integration dependencies",
        "Technical debt"
      ],
      "impact_factors" => [
        "System downtime",
        "Data loss",
        "Performance degradation",
        "Security vulnerabilities",
        "Scalability issues"
      ],
      "mitigation_guidelines" => [
        "Technical review",
        "Proof of concept",
        "Redundancy",
        "Automated testing",
        "Performance monitoring"
      ],
      "review_frequency_days" => 14
    }
  },
  %{
    name: "Business Risk",
    description: "Risks affecting business operations and objectives",
    color: "#FFA500",
    assessment_criteria: %{
      "probability_factors" => [
        "Market conditions",
        "Competition",
        "Regulatory changes",
        "Economic factors",
        "Stakeholder alignment"
      ],
      "impact_factors" => [
        "Revenue loss",
        "Market share",
        "Customer satisfaction",
        "Brand reputation",
        "Operational costs"
      ],
      "mitigation_guidelines" => [
        "Market analysis",
        "Contingency planning",
        "Insurance",
        "Stakeholder management",
        "Compliance monitoring"
      ],
      "review_frequency_days" => 30
    }
  }
]

categories = Enum.map(risk_categories, fn category ->
  Repo.insert!(%Resolvinator.Risks.Category{
    name: category.name,
    description: category.description,
    color: category.color,
    assessment_criteria: category.assessment_criteria,
    project_id: project1.id,
    creator_id: user1.id
  })
end)

# Add some hidden categories
hidden_categories = [
  %{
    name: "Archived Technical Risk",
    description: "Old technical risks category",
    color: "#999999",
    hidden: true,
    hidden_at: DateTime.utc_now(),
    hidden_by_id: user1.id
  }
]

created_hidden_categories = Enum.map(hidden_categories, fn category ->
  Repo.insert!(%Resolvinator.Risks.Category{
    name: category.name,
    description: category.description,
    color: category.color,
    hidden: category.hidden,
    hidden_at: category.hidden_at,
    hidden_by_id: category.hidden_by_id,
    project_id: project1.id,
    creator_id: user1.id
  })
end)

# Create Actors
actors = [
  %{
    name: "Development Team",
    type: "team",
    description: "Core development team responsible for implementation",
    role: "responsible",
    influence_level: "high",
    contact_info: %{
      "email" => "dev-team@example.com",
      "slack" => "#dev-team"
    },
    project_id: project1.id,
    creator_id: user1.id
  },
  %{
    name: "Security Auditor",
    type: "individual",
    description: "External security consultant",
    role: "consulted",
    influence_level: "medium",
    contact_info: %{
      "email" => "security@example.com",
      "phone" => "555-0123"
    },
    project_id: project1.id,
    creator_id: user1.id
  }
]

created_actors = Enum.map(actors, fn actor ->
  Repo.insert!(%Resolvinator.Actors.Actor{
    name: actor.name,
    type: actor.type,
    description: actor.description,
    role: actor.role,
    influence_level: actor.influence_level,
    contact_info: actor.contact_info,
    project_id: actor.project_id,
    creator_id: actor.creator_id
  })
end)

# Create Risks with more detailed attributes
risks = [
  %{
    name: "Data Migration Failure",
    description: "Risk of data loss or corruption during migration",
    probability: "likely",
    impact: "major",
    priority: "high",
    status: "analyzing",
    detection_date: ~D[2024-03-01],
    review_date: ~D[2024-03-15],
    metadata: %{
      "technical_complexity" => "high",
      "data_volume" => "large",
      "previous_incidents" => 2,
      "affected_systems" => ["CRM", "Billing", "Analytics"],
      "risk_indicators" => [
        "Complex data transformations",
        "Legacy system constraints",
        "Tight timeline"
      ],
      "factor_ratings" => %{
        "probability_factors" => %{
          "technical_complexity" => 4,
          "team_expertise" => 3,
          "technology_maturity" => 2,
          "integration_dependencies" => 4,
          "technical_debt" => 3
        },
        "impact_factors" => %{
          "system_downtime" => 4,
          "data_loss" => 5,
          "performance_degradation" => 3,
          "security_vulnerabilities" => 2,
          "scalability_issues" => 3
        }
      }
    },
    category_id: Enum.at(categories, 0).id,
    project_id: project1.id,
    creator_id: user1.id
  },
  %{
    name: "Market Competition",
    description: "New competitor entering the market with innovative features",
    probability: "possible",
    impact: "severe",
    priority: "critical",
    status: "mitigating",
    detection_date: ~D[2024-03-15],
    review_date: ~D[2024-03-30],
    metadata: %{
      "market_share_impact" => "25%",
      "competitor_analysis" => %{
        "strengths" => ["Innovation", "Pricing", "Market presence"],
        "weaknesses" => ["New entrant", "Limited track record"]
      },
      "affected_products" => ["Core Platform", "Enterprise Suite"],
      "risk_indicators" => [
        "Declining market share",
        "Customer feedback",
        "Industry trends"
      ],
      "factor_ratings" => %{
        "probability_factors" => %{
          "market_conditions" => 4,
          "competition" => 5,
          "regulatory_changes" => 2,
          "economic_factors" => 3,
          "stakeholder_alignment" => 3
        },
        "impact_factors" => %{
          "revenue_loss" => 5,
          "market_share" => 4,
          "customer_satisfaction" => 4,
          "brand_reputation" => 3,
          "operational_costs" => 3
        }
      }
    },
    category_id: Enum.at(categories, 1).id,
    project_id: project1.id,
    creator_id: user1.id
  }
]

created_risks = Enum.map(risks, fn risk ->
  Repo.insert!(%Resolvinator.Risks.Risk{
    name: risk.name,
    description: risk.description,
    probability: risk.probability,
    impact: risk.impact,
    priority: risk.priority,
    status: risk.status,
    detection_date: risk.detection_date,
    review_date: risk.review_date,
    metadata: risk.metadata,
    category_id: risk.category_id,
    project_id: risk.project_id,
    creator_id: risk.creator_id
  })
end)

# Create Impacts
impacts = [
  %{
    description: "Potential loss of historical data",
    area: "technical",
    severity: "high",
    likelihood: "medium",
    estimated_cost: Decimal.new("50000"),
    timeframe: "immediate",
    notes: "Critical customer data could be affected",
    risk_id: Enum.at(created_risks, 0).id,
    creator_id: user1.id
  },
  %{
    description: "Market share reduction",
    area: "financial",
    severity: "medium",
    likelihood: "high",
    estimated_cost: Decimal.new("100000"),
    timeframe: "3 months",
    notes: "Estimated 10% revenue impact",
    risk_id: Enum.at(created_risks, 1).id,
    creator_id: user1.id
  }
]

created_impacts = Enum.map(impacts, fn impact ->
  Repo.insert!(%Resolvinator.Risks.Impact{
    description: impact.description,
    area: impact.area,
    severity: impact.severity,
    likelihood: impact.likelihood,
    estimated_cost: impact.estimated_cost,
    timeframe: impact.timeframe,
    notes: impact.notes,
    risk_id: impact.risk_id,
    creator_id: impact.creator_id
  })
end)

# Create Mitigations
mitigations = [
  %{
    description: "Implement automated data validation",
    strategy: "mitigate",
    status: "in_progress",
    effectiveness: "high",
    cost: Decimal.new("25000"),
    start_date: ~D[2024-03-15],
    target_date: ~D[2024-04-15],
    notes: "Including checksums and rollback procedures",
    risk_id: Enum.at(created_risks, 0).id,
    creator_id: user1.id
  },
  %{
    description: "Enhance product differentiation",
    strategy: "mitigate",
    status: "planned",
    effectiveness: "medium",
    cost: Decimal.new("75000"),
    start_date: ~D[2024-04-01],
    target_date: ~D[2024-06-30],
    notes: "Focus on unique features and customer experience",
    risk_id: Enum.at(created_risks, 1).id,
    creator_id: user1.id
  }
]

created_mitigations = Enum.map(mitigations, fn mitigation ->
  Repo.insert!(%Resolvinator.Risks.Mitigation{
    description: mitigation.description,
    strategy: mitigation.strategy,
    status: mitigation.status,
    effectiveness: mitigation.effectiveness,
    cost: mitigation.cost,
    start_date: mitigation.start_date,
    target_date: mitigation.target_date,
    notes: mitigation.notes,
    risk_id: mitigation.risk_id,
    creator_id: mitigation.creator_id
  })
end)

# Create Mitigation Tasks
tasks = [
  %{
    name: "Design validation framework",
    description: "Create technical design for data validation",
    status: "in_progress",
    due_date: ~D[2024-03-30],
    mitigation_id: Enum.at(created_mitigations, 0).id,
    creator_id: user1.id,
    assignee_id: user2.id
  },
  %{
    name: "Market research",
    description: "Analyze competitor features and pricing",
    status: "planned",
    due_date: ~D[2024-04-15],
    mitigation_id: Enum.at(created_mitigations, 1).id,
    creator_id: user1.id,
    assignee_id: user2.id
  }
]

created_tasks = Enum.map(tasks, fn task ->
  Repo.insert!(%Resolvinator.Risks.MitigationTask{
    name: task.name,
    description: task.description,
    status: task.status,
    due_date: task.due_date,
    mitigation_id: task.mitigation_id,
    creator_id: task.creator_id,
    assignee_id: task.assignee_id
  })
end)

# Create relationships
Enum.each(created_actors, fn actor ->
  Repo.insert_all("actor_risk_responsibilities", [
    %{
      actor_id: actor.id,
      risk_id: Enum.at(created_risks, 0).id,
      inserted_at: now,
      updated_at: now
    }
  ])
end)
