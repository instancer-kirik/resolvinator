defmodule ResolvinatorWeb.SupplierLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Suppliers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:supplier, Suppliers.get_supplier!(id))}
  end

  defp page_title(:show), do: "Show Supplier"
  defp page_title(:edit), do: "Edit Supplier"
end
