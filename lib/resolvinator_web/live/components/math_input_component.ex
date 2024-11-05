defmodule ResolvinatorWeb.Components.MathInputComponent do
  use ResolvinatorWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="math-input-container">
      <div class="flex space-x-2 mb-4">
        <.button
          :for={tool <- math_tools()}
          type="button"
          phx-click="insert-symbol"
          phx-value-symbol={tool.symbol}
          phx-target={@myself}
        >
          <%= tool.label %>
        </.button>
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div>
          <.input
            field={@form[:latex]}
            type="textarea"
            label="LaTeX Input"
            phx-change="preview-math"
            phx-target={@myself}
          />

          <%= if @show_proof_structure do %>
            <div class="mt-4">
              <label class="block text-sm font-medium text-gray-700">Proof Structure</label>
              <div class="space-y-2">
                <.input
                  field={@form[:assumptions]}
                  type="text"
                  placeholder="Given/Assumptions"
                />

                <div class="proof-steps" id="proof-steps" phx-update="append">
                  <%= for {step, i} <- Enum.with_index(@proof_steps) do %>
                    <div class="flex items-center space-x-2">
                      <span class="text-gray-500"><%= i + 1 %>.</span>
                      <.input
                        field={@form[:"step_#{i}"]}
                        type="text"
                        value={step}
                        placeholder="Proof step"
                      />
                      <.button
                        type="button"
                        phx-click="remove-step"
                        phx-value-index={i}
                        phx-target={@myself}
                      >
                        &times;
                      </.button>
                    </div>
                  <% end %>
                </div>

                <.button
                  type="button"
                  phx-click="add-step"
                  phx-target={@myself}
                  class="mt-2"
                >
                  Add Step
                </.button>

                <.input
                  field={@form[:conclusion]}
                  type="text"
                  placeholder="Therefore..."
                />
              </div>
            </div>
          <% end %>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Preview</label>
          <div class="border rounded-lg p-4 bg-white">
            <%= if @preview_error do %>
              <div class="text-red-600 text-sm"><%= @preview_error %></div>
            <% else %>
              <div id="math-preview" phx-update="ignore">
                <%= raw(@preview_html) %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:preview_html, "")
     |> assign(:preview_error, nil)
     |> assign(:proof_steps, [])
     |> assign(:show_proof_structure, false)}
  end

  @impl true
  def handle_event("preview-math", %{"latex" => latex}, socket) do
    case render_math(latex) do
      {:ok, html} ->
        {:noreply, assign(socket, preview_html: html, preview_error: nil)}
      {:error, error} ->
        {:noreply, assign(socket, preview_error: error)}
    end
  end

  defp math_tools do
    [
      %{label: "∫", symbol: "\\int"},
      %{label: "∑", symbol: "\\sum"},
      %{label: "∏", symbol: "\\prod"},
      %{label: "√", symbol: "\\sqrt"},
      %{label: "≤", symbol: "\\leq"},
      %{label: "≥", symbol: "\\geq"},
      %{label: "≠", symbol: "\\neq"},
      %{label: "∈", symbol: "\\in"},
      %{label: "⊆", symbol: "\\subseteq"},
      %{label: "→", symbol: "\\rightarrow"},
      %{label: "ℝ", symbol: "\\mathbb{R}"},
      %{label: "ℕ", symbol: "\\mathbb{N}"},
      %{label: "ℤ", symbol: "\\mathbb{Z}"},
      %{label: "ℚ", symbol: "\\mathbb{Q}"}
    ]
  end

  defp render_math(latex) do
    # You'll need to implement actual LaTeX rendering
    # Could use MathJax, KaTeX, or a server-side renderer
    {:ok, "<div class='math'>#{latex}</div>"}
  end
end
