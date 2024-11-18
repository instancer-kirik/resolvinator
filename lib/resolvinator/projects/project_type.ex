defmodule Resolvinator.Projects.ProjectType do
	@moduledoc """
	Defines the behaviour and implementation for different project types.
	Project types can implement additional behaviors like Calendar functionality
	through the Resolvinator.Projects.Behaviors.* modules.
	"""

	@doc """
	Validates the settings for a specific project type.
	Must return :ok or {:error, message}
	"""
	@callback validate_settings(settings :: map()) :: :ok | {:error, String.t()}
1. Software Development Projects
Causes:
Technological Advancements: Development of new frameworks or technologies.
Customer Demand: Need for new applications or features.
Business Expansion: Company growth requiring new internal tools or platforms.
Process Automation: Reducing manual work to increase efficiency.
2. Construction Projects
Causes:
Urban Development: Population growth requiring housing and infrastructure.
Business Expansion: Building new offices or industrial facilities.
Public Infrastructure: Government projects like roads, bridges, and airports.
Renovation and Repairs: Upgrading existing structures for safety or aesthetics.
3. Research and Development (R&D) Projects
Causes:
Innovation Goals: Creating new products or improving existing ones.
Competitive Advantage: Staying ahead of competitors.
Regulatory Compliance: Meeting new legal standards.
Scientific Inquiry: Advancing knowledge in specific fields.
4. Marketing and Branding Projects
Causes:
Market Penetration: Expanding brand visibility.
Product Launches: Promoting new products or services.
Rebranding Efforts: Updating company image or message.
Seasonal Campaigns: Targeting holidays or special events.
5. IT Infrastructure Projects
Causes:
System Upgrades: Replacing outdated hardware or software.
Cybersecurity Needs: Protecting against evolving threats.
Scalability Requirements: Supporting business growth.
Disaster Recovery Planning: Preparing for potential data loss.
6. Educational and Training Projects
Causes:
Skill Development: Training employees or students in new skills.
Curriculum Updates: Adapting to new educational standards.
Onboarding Programs: Integrating new employees or students.
Public Outreach: Spreading awareness about important topics.
7. Environmental Projects
Causes:
Sustainability Goals: Reducing carbon footprint and environmental impact.
Conservation Efforts: Protecting natural habitats and wildlife.
Waste Management: Improving recycling and waste reduction.
Regulatory Compliance: Meeting environmental laws.
8. Healthcare Projects
Causes:
Public Health Initiatives: Responding to health crises (e.g., pandemics).
Facility Upgrades: Building or updating hospitals and clinics.
Medical Research: Developing new treatments or vaccines.
Patient Care Improvements: Enhancing healthcare services and systems.
9. Nonprofit and Community Projects
Causes:
Social Welfare: Addressing homelessness, hunger, or other community needs.
Educational Outreach: Providing resources and support for underprivileged groups.
Cultural Preservation: Protecting historical sites and traditions.
Disaster Relief: Responding to natural disasters or emergencies.
10. Financial and Economic Projects
Causes:
Economic Stimulus: Boosting the economy through targeted investments.
New Business Ventures: Launching startups or financial services.
Cost Reduction: Implementing strategies to reduce company expenses.
Compliance Projects: Meeting new financial regulations.
11. Creative and Artistic Projects
Causes:
Cultural Expression: Supporting artists, music, theater, and film.
Innovation in Design: Exploring new trends in art and design.
Public Art Initiatives: Beautifying communities and public spaces.
Event Planning: Organizing concerts, exhibitions, and festivals.
12. Logistics and Supply Chain Projects
Causes:
Efficiency Optimization: Streamlining supply chain processes.
Distribution Expansion: Reaching new markets and areas.
Technological Integration: Implementing new logistics software.
Risk Management: Addressing vulnerabilities in supply routes.
13. Energy Projects
Causes:
Renewable Energy Goals: Installing solar, wind, or hydroelectric systems.
Energy Efficiency: Upgrading to more efficient power sources.
Infrastructure Development: Building power plants and grids.
Sustainability Commitments: Reducing reliance on fossil fuels.
14. Policy and Governance Projects
Causes:
Legislative Changes: Enforcing new laws or regulations.
Public Administration: Implementing better governance systems.
Public Safety: Enhancing law enforcement and emergency response.
International Relations: Diplomatic projects and peacekeeping missions.
15. Product Management and Enhancement Projects
Causes:
Feature Requests: Adding new capabilities to existing products.
Quality Improvements: Refining product features or user experience.
User Feedback: Addressing customer concerns or suggestions.
Market Adaptation: Adjusting to competitor offerings.

	@doc """
	Returns the default settings for a specific project type.
	"""
	@callback default_settings() :: map()

	@doc """
	Returns the required fields for a specific project type.
	"""
	@callback required_fields() :: list(atom())

	@project_types %{
		"software" => Resolvinator.Projects.Types.Software,
		"research" => Resolvinator.Projects.Types.Research,
		"infrastructure" => Resolvinator.Projects.Types.Infrastructure,
		"marketing" => Resolvinator.Projects.Types.Marketing,
		"education" => Resolvinator.Projects.Types.Education,
		"healthcare" => Resolvinator.Projects.Types.Healthcare,
		"construction" => Resolvinator.Projects.Types.Construction,
		"environmental" => Resolvinator.Projects.Types.Environmental,
		"nonprofit" => Resolvinator.Projects.Types.Nonprofit,
		"creative" => Resolvinator.Projects.Types.Creative,
		"logistics" => Resolvinator.Projects.Types.Logistics,
		"energy" => Resolvinator.Projects.Types.Energy,
		"policy" => Resolvinator.Projects.Types.Policy,
		"financial" => Resolvinator.Projects.Types.Financial,
		"product" => Resolvinator.Projects.Types.Product

	}

	@doc """
	Gets the implementation module for a given project type.
	Returns nil if the project type is not supported.
	"""
	def get_implementation(project_type) when is_binary(project_type) do
		Map.get(@project_types, project_type)
	end
	def get_implementation(_), do: nil

	@doc """
	Returns a list of all supported project types.
	"""
	def supported_types do
		Map.keys(@project_types)
	end

	@doc """
	Returns a map of project types grouped by their primary domain
	"""
	def project_type_categories do
		%{
			"development" => ["software", "product"],
			"infrastructure" => ["infrastructure", "construction", "energy"],
			"research_and_innovation" => ["research", "healthcare"],
			"business" => ["marketing", "financial", "logistics"],
			"social" => ["education", "nonprofit", "policy"],
			"creative" => ["creative"],
			"sustainability" => ["environmental"]

		}
	end
end