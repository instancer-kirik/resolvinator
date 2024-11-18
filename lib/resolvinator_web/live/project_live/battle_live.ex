defmodule ResolvinatorWeb.BattleLive do
  use ResolvinatorWeb, :live_view
  alias Resolvinator.Wonderdome
  
  @impl true
  def mount(%{"id" => battle_id}, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Resolvinator.PubSub, "battle:#{battle_id}")
    end
    
    battle = Wonderdome.get_battle_with_ships!(battle_id)
    
    {:ok,
     assign(socket,
       battle: battle,
       current_ship: battle.ship_one,
       voted: false,
       feedback_type: "praise",
       page: "overview"  # overview, details, voting, feedback
     )}
  end

  @impl true
  def handle_event("switch_ship", _, socket) do
    current = socket.assigns.current_ship
    other_ship = if current.id == socket.assigns.battle.ship_one_id,
      do: socket.assigns.battle.ship_two,
      else: socket.assigns.battle.ship_one
      
    {:noreply, assign(socket, current_ship: other_ship)}
  end
  
  @impl true
  def handle_event("cast_vote", %{"ship_id" => ship_id, "categories" => categories}, socket) do
    with {:ok, vote} <- Wonderdome.create_vote(socket.assigns.battle, socket.assigns.current_user, ship_id, categories) do
      {:noreply, assign(socket, voted: true)}
    end
  end
  
  @impl true
  def handle_event("submit_feedback", %{"feedback" => params}, socket) do
    with {:ok, feedback} <- Wonderdome.create_feedback(socket.assigns.battle, socket.assigns.current_user, params) do
      {:noreply, socket}
    end
  end
end 