defmodule ResolvinatorWeb.Components.FormComponents do
  use Phoenix.Component
  import ResolvinatorWeb.CoreComponents

  attr :title, :string, default: nil
  slot :inner_block, required: true

  def form_group(assigns) do
    ~H"""
    <div class="space-y-4">
      <%= if @title do %>
        <h3 class="text-lg font-medium leading-6 text-gray-900"><%= @title %></h3>
      <% end %>
      <div class="space-y-4">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :field, :any, required: true
  attr :options, :list, required: true
  attr :rest, :global

  def checkbox_group(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= for {label, value} <- @options do %>
        <label class="inline-flex items-center gap-2">
          <input
            type="checkbox"
            name={@field.name}
            value={value}
            checked={value in Phoenix.HTML.Form.input_value(@field.form, @field.field)}
            class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
            {@rest}
          />
          <span class="text-sm text-gray-700"><%= label %></span>
        </label>
      <% end %>
    </div>
    """
  end
end 