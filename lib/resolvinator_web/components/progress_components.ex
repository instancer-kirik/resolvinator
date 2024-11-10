defmodule ResolvinatorWeb.Components.ProgressComponents do
  use Phoenix.Component

  attr :progress, :integer, required: true
  attr :class, :string, default: ""
  attr :color, :string, default: "blue"

  def progress_bar(assigns) do
    ~H"""
    <div class={[
      "w-full bg-gray-200 rounded-full h-2.5 dark:bg-gray-700",
      @class
    ]}>
      <div
        class={"h-2.5 rounded-full bg-#{@color}-600"}
        style={"width: #{@progress}%"}
        role="progressbar"
        aria-valuenow={@progress}
        aria-valuemin="0"
        aria-valuemax="100"
      >
      </div>
    </div>
    """
  end

  # Optional: Add a more detailed progress indicator
  attr :progress, :integer, required: true
  attr :label, :string, default: nil
  attr :class, :string, default: ""
  attr :color, :string, default: "blue"

  def progress_indicator(assigns) do
    ~H"""
    <div class={["space-y-2", @class]}>
      <div class="flex justify-between text-sm font-medium">
        <span><%= @label || "Progress" %></span>
        <span><%= @progress %>%</span>
      </div>
      <.progress_bar progress={@progress} color={@color} />
    </div>
    """
  end
end 