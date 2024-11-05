defmodule ResolvinatorWeb.Components.MathImageUploadComponent do
  use ResolvinatorWeb, :live_component
  alias Phoenix.LiveView.JS

  @impl true
  def render(assigns) do
    ~H"""
    <div class="math-image-upload">
      <div class="flex space-x-4 mb-4">
        <div class="w-2/3">
          <.live_file_input
            upload={@uploads.math_image}
            class="hidden"
            id="math-image-input"
          />

          <label for="math-image-input" class="cursor-pointer">
            <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
              <%= if @image_preview do %>
                <img src={@image_preview} class="mx-auto max-h-64" />
              <% else %>
                <div class="text-gray-500">
                  Click or drag to upload mathematical diagram
                </div>
              <% end %>
            </div>
          </label>

          <%= if @uploads.math_image.entries != [] do %>
            <%= for entry <- @uploads.math_image.entries do %>
              <div class="mt-2">
                <div class="flex items-center space-x-2">
                  <span class="text-sm font-medium"><%= entry.client_name %></span>
                  <button
                    type="button"
                    phx-click="cancel-upload"
                    phx-value-ref={entry.ref}
                    phx-target={@myself}
                    class="text-red-600 hover:text-red-800"
                  >
                    &times;
                  </button>
                </div>

                <div class="mt-2">
                  <.progress_bar
                    value={entry.progress}
                    max="100"
                    class="w-full h-2 bg-blue-200 rounded-full"
                  />
                </div>
              </div>
            <% end %>
          <% end %>
        </div>

        <div class="w-1/3">
          <div class="space-y-4">
            <.input
              field={@form[:visualization_type]}
              type="select"
              label="Visualization Type"
              options={[
                {"Geometric Diagram", "diagram"},
                {"Function Plot", "plot"},
                {"Graph", "graph"},
                {"Geometric Proof", "geometric_proof"}
              ]}
            />

            <div class="space-y-2">
              <label class="block text-sm font-medium text-gray-700">
                Image Options
              </label>

              <div class="flex items-center">
                <input
                  type="checkbox"
                  checked={@show_grid}
                  phx-click="toggle-grid"
                  phx-target={@myself}
                  class="mr-2"
                />
                <span class="text-sm">Show Grid</span>
              </div>

              <div class="flex items-center">
                <input
                  type="checkbox"
                  checked={@enable_annotations}
                  phx-click="toggle-annotations"
                  phx-target={@myself}
                  class="mr-2"
                />
                <span class="text-sm">Enable Annotations</span>
              </div>
            </div>

            <%= if @enable_annotations do %>
              <div class="annotation-tools">
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  Annotation Tools
                </label>
                <div class="flex flex-wrap gap-2">
                  <.button
                    :for={tool <- annotation_tools()}
                    type="button"
                    phx-click="select-tool"
                    phx-value-tool={tool.type}
                    phx-target={@myself}
                    class={[
                      "p-2",
                      @selected_tool == tool.type && "bg-blue-600"
                    ]}
                  >
                    <%= tool.icon %>
                  </.button>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <%= if @enable_annotations && @image_preview do %>
        <div
          id="annotation-canvas"
          phx-hook="MathImageAnnotations"
          data-tool={@selected_tool}
          class="relative border rounded-lg overflow-hidden"
        >
          <img src={@image_preview} class="max-w-full" />
          <canvas
            class="absolute inset-0 pointer-events-auto"
            style="z-index: 10;"
          />
        </div>
      <% end %>
    </div>
    """
  end

  defp annotation_tools do
    [
      %{type: "arrow", icon: "→"},
      %{type: "line", icon: "—"},
      %{type: "circle", icon: "○"},
      %{type: "rectangle", icon: "□"},
      %{type: "text", icon: "T"},
      %{type: "angle", icon: "∠"}
    ]
  end
end
