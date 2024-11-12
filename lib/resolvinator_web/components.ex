defmodule ResolvinatorWeb.Components do
  defmacro __using__(_) do
    quote do
      import Phoenix.Component
      import ResolvinatorWeb.CoreComponents
      import ResolvinatorWeb.Components.NavigationComponents
    end
  end
end 