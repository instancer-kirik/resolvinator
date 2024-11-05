defmodule ResolvinatorWeb.EventBuilderComponents do
  use Phoenix.Component
  import ResolvinatorWeb.CoreComponents

  def basic_info_form(assigns) do
    ~H"""
    <div class="space-y-6">
      <.form_group>
        <:title>Event Details</:title>
        <.input
          field={@form_data[:title]}
          type="text"
          label="Event Title"
          placeholder="Brief description of what happened"
        />
        <.input
          field={@form_data[:event_type]}
          type="select"
          label="Event Type"
          options={[
            {"Risk Occurrence", "risk_occurrence"},
            {"Mitigation Outcome", "mitigation_outcome"},
            {"Impact Manifestation", "impact_manifestation"},
            {"Control Failure", "control_failure"},
            {"Near Miss", "near_miss"}
          ]}
        />
        <.input
          field={@form_data[:description]}
          type="textarea"
          label="Detailed Description"
          placeholder="Provide a detailed account of the event"
        />
      </.form_group>

      <.form_group>
        <:title>Timing & Location</:title>
        <.input
          field={@form_data[:occurred_at]}
          type="datetime-local"
          label="When did it occur?"
        />
        <.input
          field={@form_data[:detected_at]}
          type="datetime-local"
          label="When was it detected?"
        />
        <.input
          field={@form_data[:location]}
          type="text"
          label="Location"
          placeholder="Where did this occur?"
        />
      </.form_group>
    </div>
    """
  end

  def impact_details_form(assigns) do
    ~H"""
    <div class="space-y-6">
      <.form_group>
        <:title>Impact Assessment</:title>
        <.input
          field={@form_data[:severity]}
          type="select"
          label="Severity Level"
          options={[
            {"Negligible", "negligible"},
            {"Minor", "minor"},
            {"Moderate", "moderate"},
            {"Major", "major"},
            {"Severe", "severe"}
          ]}
        />
        <.input
          field={@form_data[:financial_impact]}
          type="number"
          label="Financial Impact"
          placeholder="Estimated cost in your currency"
        />
      </.form_group>

      <.form_group>
        <:title>Impact Areas</:title>
        <.checkbox_group
          field={@form_data[:impact_areas]}
          options={[
            {"Financial", "financial"},
            {"Operational", "operational"},
            {"Technical", "technical"},
            {"Reputational", "reputational"},
            {"Regulatory", "regulatory"},
            {"Safety", "safety"}
          ]}
        />
      </.form_group>
    </div>
    """
  end

  # ... Additional component functions for other steps ...
end
