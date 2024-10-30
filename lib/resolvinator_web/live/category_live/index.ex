defmodule ResolvinatorWeb.CategoryLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Risks
  alias Resolvinator.Risks.Category

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :risk_categories, Risks.list_risk_categories())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Risks.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Risk categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.CategoryLive.FormComponent, {:saved, category}}, socket) do
    {:noreply, stream_insert(socket, :risk_categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Risks.get_category!(id)
    {:ok, _} = Risks.delete_category(category)

    {:noreply, stream_delete(socket, :risk_categories, category)}
  end
end
