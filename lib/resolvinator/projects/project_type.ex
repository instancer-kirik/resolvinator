defmodule Resolvinator.Projects.ProjectType do
	@moduledoc """
	Defines the behaviour and implementation for different project types.
	Project types can implement additional behaviors like Calendar functionality
	through the Resolvinator.Projects.Behaviors.* modules.

	Supports natural language processing for:
	- Project type classification
	- Cause analysis
	- Requirements extraction
	- Risk assessment
	- Resource allocation suggestions
	"""

	@doc """
	Validates the settings for a specific project type.
	Must return :ok or {:error, message}
	"""
	@callback validate_settings(settings :: map()) :: :ok | {:error, String.t()}

	@doc """
	Analyzes project description using NLP to suggest project type and settings.
	"""
	@callback analyze_description(description :: String.t()) :: 
		{:ok, %{type: String.t(), confidence: float(), settings: map()}} | 
		{:error, String.t()}

	@doc """
	Extracts key requirements and goals from natural language description.
	"""
	@callback extract_requirements(description :: String.t()) ::
		{:ok, list(String.t())} | {:error, String.t()}

	@doc """
	Performs risk analysis based on project description and type.
	"""
	@callback analyze_risks(description :: String.t(), settings :: map()) ::
		{:ok, list(%{risk: String.t(), probability: float(), impact: float()})} |
		{:error, String.t()}

	@doc """
	Returns the default settings for a specific project type.
	"""
	@callback default_settings() :: map()

	@doc """
	Returns the required fields for a specific project type.
	"""
	@callback required_fields() :: list(atom())

	# Project Types with their implementations
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
		"product" => Resolvinator.Projects.Types.Product,
		"multimedia" => Resolvinator.Projects.Types.Multimedia,
		"analytics" => Resolvinator.Projects.Types.Analytics,
		"sports" => Resolvinator.Projects.Types.Sports
	}

	# NLP-based classification thresholds
	@confidence_threshold 0.75
	@similarity_threshold 0.85

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
			"business" => ["marketing", "financial", "logistics", "analytics"],
			"social" => ["education", "nonprofit", "policy"],
			"creative" => ["creative", "multimedia"],
			"sustainability" => ["environmental"],
			"sports_and_entertainment" => ["sports"]
		}
	end

	@doc """
	Analyzes a project description and suggests the most appropriate project type
	along with confidence score and initial settings.
	"""
	def analyze_project_description(description) when is_binary(description) do
		with {:ok, embeddings} <- Resolvinator.NLP.get_embeddings(description),
				{type, confidence} <- classify_project_type(embeddings),
				{:ok, settings} <- extract_default_settings(type, description) do
			{:ok, %{
				type: type,
				confidence: confidence,
				settings: settings,
				suggested_requirements: extract_suggested_requirements(description, type),
				potential_risks: analyze_potential_risks(description, type)
			}}
		end
	end
	def analyze_project_description(_), do: {:error, "Invalid project description"}

	@doc """
	Extracts key phrases and requirements from a project description using NLP.
	"""
	def extract_key_phrases(description) when is_binary(description) do
		Resolvinator.NLP.extract_key_phrases(description)
	end

	@doc """
	Performs semantic similarity comparison between project descriptions.
	"""
	def compare_projects(description1, description2) when is_binary(description1) and is_binary(description2) do
		with {:ok, emb1} <- Resolvinator.NLP.get_embeddings(description1),
				{:ok, emb2} <- Resolvinator.NLP.get_embeddings(description2) do
			similarity = Resolvinator.NLP.compute_similarity(emb1, emb2)
			{:ok, similarity}
		end
	end

	# Private functions

	defp classify_project_type(embeddings) do
		# Implement classification logic using embeddings and project type characteristics
		# Returns {project_type, confidence_score}
		# This is a placeholder - actual implementation would use proper ML model
		{"software", 0.95}
	end

	defp extract_default_settings(type, description) do
		case get_implementation(type) do
			nil -> {:error, "Unsupported project type"}
			module -> 
				settings = module.default_settings()
				{:ok, enhance_settings_with_nlp(settings, description)}
		end
	end

	defp enhance_settings_with_nlp(settings, description) do
		# Enhance default settings using NLP insights
		# This is a placeholder - actual implementation would analyze the description
		# and adjust settings accordingly
		settings
	end

	defp extract_suggested_requirements(description, type) do
		# Extract requirements using NLP
		# This is a placeholder - actual implementation would use proper NLP analysis
		[]
	end

	defp analyze_potential_risks(description, type) do
		# Analyze risks using NLP
		# This is a placeholder - actual implementation would use proper risk analysis
		[]
	end
end