defmodule Resolvinator.Projects.Behaviors.Calendar do
	@moduledoc """
	Defines the behavior for projects that support calendar functionality.
	This allows any project type to implement calendar features like events,
	subscriptions, and sharing.
	"""

	@doc """
	Returns whether calendar functionality is enabled for this project
	"""
	@callback calendar_enabled?() :: boolean()

	@doc """
	Returns the calendar settings for the project
	"""
	@callback calendar_settings() :: map()

	@doc """
	Returns the default calendar settings
	"""
	@callback default_calendar_settings() :: map()

	@doc """
	Validates calendar-specific settings
	"""
	@callback validate_calendar_settings(settings :: map()) :: :ok | {:error, String.t()}

	@optional_callbacks [
		calendar_enabled?: 0,
		calendar_settings: 0,
		default_calendar_settings: 0,
		validate_calendar_settings: 1
	]

	def default_calendar_settings do
		%{
			sharing_enabled: true,
			subscription_enabled: true,
			default_visibility: "private",
			notification_preferences: %{
				event_updates: true,
				new_subscriptions: true,
				sharing_requests: true
			}
		}
	end
end