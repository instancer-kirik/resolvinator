defmodule ResolvinatorWeb.Layouts.NavMenu do
  use ResolvinatorWeb, :html

  def nav_menu(assigns) do
    ~H"""
    <nav class="bg-zinc-800 text-white p-4">
      <div class="container mx-auto">
        <div class="space-y-2">
          <%= if @current_user do %>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
              <div class="space-y-2">
                <h3 class="font-bold text-zinc-300">Main</h3>
                <ul class="space-y-1">
                  <li><.link navigate={~p"/problems"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Problems</.link></li>
                  <li><.link navigate={~p"/solutions"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Solutions</.link></li>
                  <li><.link navigate={~p"/advantages"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Advantages</.link></li>
                  <li><.link navigate={~p"/lessons"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Lessons</.link></li>
                  <li><.link navigate={~p"/handsigns"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Handsigns</.link></li>
                </ul>
              </div>

              <div class="space-y-2">
                <h3 class="font-bold text-zinc-300">Risk Management</h3>
                <ul class="space-y-1">
                  <li><.link navigate={~p"/risks"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Risks</.link></li>
                  <li><.link navigate={~p"/impacts"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Impacts</.link></li>
                  <li><.link navigate={~p"/mitigations"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Mitigations</.link></li>
                  <li><.link navigate={~p"/mitigation_tasks"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Tasks</.link></li>
                  <li><.link navigate={~p"/risk_analysis"} class="hover:text-gray-300">Risk Analysis</.link></li>
                  <li><.link navigate={~p"/risk_assessment"} class="hover:text-gray-300">Risk Assessment</.link></li>
                  <li><.link navigate={~p"/risk_management"} class="hover:text-gray-300">Risk Management</.link></li>
                </ul>
              </div>

              <div class="space-y-2">
                <h3 class="font-bold text-zinc-300">Resources</h3>
                <ul class="space-y-1">
                  <li><.link navigate={~p"/resources"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Resources</.link></li>
                  <li><.link navigate={~p"/suppliers"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Suppliers</.link></li>
                  <li><.link navigate={~p"/documents"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Documents</.link></li>
                  <li><.link navigate={~p"/requirements"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Requirements</.link></li>
                </ul>
              </div>

              <div class="space-y-2">
                <h3 class="font-bold text-zinc-300">Organization</h3>
                <ul class="space-y-1">
                  <li><.link navigate={~p"/actors"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Actors</.link></li>
                  <li><.link navigate={~p"/categories"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Categories</.link></li>
                  <li><.link navigate={~p"/messages"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">Messages</.link></li>
                  <li><.link navigate={~p"/news/broadcast"} class="text-[0.8125rem] leading-6 text-white font-semibold hover:text-zinc-300">News</.link></li>
                </ul>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </nav>
    """
  end
end 