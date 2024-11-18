defmodule Resolvinator.Projects.Behaviors.Collaboration do
	@moduledoc """
	Defines the behavior for projects that support team collaboration functionality.
	This allows project types to implement shared features like team management,
	permissions, and communication channels.
	"""

	@doc """
	Returns whether collaboration features are enabled for this project
	"""
	@callback collaboration_enabled?() :: boolean()

	@doc """
	Returns the collaboration settings for the project
	"""
	@callback collaboration_settings() :: map()

	@doc """
	Returns the roles and permissions configuration
	"""
	@callback roles_and_permissions() :: map()

	@doc """
	Validates collaboration-specific settings
	"""
	@callback validate_collaboration_settings(settings :: map()) :: :ok | {:error, String.t()}

	@optional_callbacks [
		collaboration_enabled?: 0,
		collaboration_settings: 0,
		roles_and_permissions: 0,
		validate_collaboration_settings: 1
	]

	def default_collaboration_settings do
		%{
			team_visibility: "private",
			member_invite_permission: "admin_only", 
			default_member_role: "viewer",
			communication_channels: %{
				comments_enabled: true,
				direct_messages_enabled: true,
				announcements_enabled: true
			}
		}
	end
end