defmodule ResolvinatorWeb.Components.RelationshipModalComponent do
  use ResolvinatorWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <.modal id={"#{@id}-modal"} show={true} on_cancel={@on_cancel}>
      <:title><%= @title %></:title>
      <:subtitle><%= @subtitle %></:subtitle>

      <div class="space-y-6">
        <div class="available-items">
          <.header class="text-lg font-semibold">
            Available <%= @item_type %>
          </.header>
          <div class="mt-4">
            <%= for item <- @available_items do %>
              <div class="flex items-center justify-between py-2 border-b">
                <span class="text-sm font-medium"><%= item.name %></span>
                <.button
                  phx-click="add_relationship"
                  phx-value-item-id={item.id}
                  phx-target={@myself}
                  size="sm"
                >
                  Add
                </.button>
              </div>
            <% end %>
          </div>
        </div>

        <div class="related-items mt-6">
          <.header class="text-lg font-semibold">
            Related <%= @item_type %>
          </.header>
          <div class="mt-4">
            <%= for item <- @related_items do %>
              <div class="flex items-center justify-between py-2 border-b">
                <span class="text-sm font-medium"><%= item.name %></span>
                <.button
                  phx-click="remove_relationship"
                  phx-value-item-id={item.id}
                  phx-target={@myself}
                  size="sm"
                  variant="danger"
                >
                  Remove
                </.button>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </.modal>
    """
  end

  @impl true
  def handle_event("add_relationship", %{"item-id" => item_id}, socket) do
    send(self(), {:add_relationship, socket.assigns.relationship_type, item_id})
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_relationship", %{"item-id" => item_id}, socket) do
    send(self(), {:remove_relationship, socket.assigns.relationship_type, item_id})
    {:noreply, socket}
  end
end 