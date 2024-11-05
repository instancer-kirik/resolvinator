defmodule ResolvinatorWeb.AIReviewComponent do
  use Phoenix.Component
  import ResolvinatorWeb.CoreComponents

  def ai_review(assigns) do
    ~H"""
    <div class="space-y-6">
      <h3 class="text-lg font-medium">AI Analysis & Recommendations</h3>

      <%= if @loading do %>
        <div class="animate-pulse space-y-4">
          <div class="h-4 bg-gray-200 rounded w-3/4"></div>
          <div class="h-4 bg-gray-200 rounded w-5/6"></div>
          <div class="h-4 bg-gray-200 rounded w-2/3"></div>
        </div>
      <% else %>
        <%= if @suggestions do %>
          <div class="prose max-w-none">
            <div class="bg-blue-50 p-4 rounded-lg">
              <h4 class="text-blue-800">Similar Events</h4>
              <p class="text-blue-700"><%= @suggestions.similar_events %></p>
            </div>

            <div class="bg-yellow-50 p-4 rounded-lg mt-4">
              <h4 class="text-yellow-800">Risk Assessment</h4>
              <p class="text-yellow-700"><%= @suggestions.risk_assessment %></p>
            </div>

            <div class="bg-green-50 p-4 rounded-lg mt-4">
              <h4 class="text-green-800">Recommended Actions</h4>
              <p class="text-green-700"><%= @suggestions.recommended_actions %></p>
            </div>

            <div class="bg-purple-50 p-4 rounded-lg mt-4">
              <h4 class="text-purple-800">Prevention Suggestions</h4>
              <p class="text-purple-700"><%= @suggestions.prevention_measures %></p>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end
end
