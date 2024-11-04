defmodule ResolvinatorWeb.SecureTextComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <canvas
      id={"canvas-#{@id}"}
      phx-hook="SecureText"
      data-text={@text}
      class="secure-text"
    />
    """
  end
end
