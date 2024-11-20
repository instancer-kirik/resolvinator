defmodule ResolvinatorWeb.BattleLive do
  use ResolvinatorWeb, :live_view
  alias Resolvinator.Wonderdome
  
  @impl true
  def mount(%{"id" => battle_id}, _session, socket) do
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
    case Wonderdome.create_vote(socket.assigns.battle, socket.assigns.current_user, ship_id, categories) do
      {:ok, _vote} -> {:noreply, assign(socket, voted: true)}
      {:error, _} -> {:noreply, socket}
    end
  end
  
  @impl true
  def handle_event("submit_feedback", %{"feedback" => params}, socket) do
    case Wonderdome.create_feedback(socket.assigns.battle, socket.assigns.current_user, params) do
      {:ok, _feedback} -> {:noreply, socket}
      {:error, _} -> {:noreply, socket}
    end
  end

  # Function components
  def video_showcase(assigns) do
    ~H"""
    <div class="video-showcase">
      <video controls>
        <source src={@showcase_data.video_url} type="video/mp4">
        Your browser does not support the video tag.
      </video>
    </div>
    """
  end

  def interactive_showcase(assigns) do
    ~H"""
    <div class="interactive-showcase">
      <iframe src={@showcase_data.iframe_url} width="100%" height="500px" frameborder="0"></iframe>
    </div>
    """
  end

  def wing_showcase(assigns) do
    ~H"""
    <div class="wing-showcase">
      <div class="wings-grid">
        <%= for wing <- @wings do %>
          <div class="wing-card">
            <h3><%= wing.name %></h3>
            <p><%= wing.description %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def default_showcase(assigns) do
    ~H"""
    <div class="default-showcase">
      <div class="ship-info">
        <h3><%= @ship.name %></h3>
        <p><%= @ship.description %></p>
      </div>
    </div>
    """
  end

  def voting_form(assigns) do
    ~H"""
    <div class="voting-form">
      <h3>Vote for this project</h3>
      <form phx-submit="cast_vote">
        <input type="hidden" name="ship_id" value={@current_ship.id}>
        <div class="voting-categories">
          <label>
            <input type="checkbox" name="categories[]" value="innovation">
            Innovation
          </label>
          <label>
            <input type="checkbox" name="categories[]" value="design">
            Design
          </label>
          <label>
            <input type="checkbox" name="categories[]" value="functionality">
            Functionality
          </label>
        </div>
        <button type="submit">Cast Vote</button>
      </form>
    </div>
    """
  end

  def feedback_form(assigns) do
    ~H"""
    <div class="feedback-form">
      <h3>Share your feedback</h3>
      <form phx-submit="submit_feedback">
        <div class="feedback-type">
          <label>
            <input type="radio" name="feedback[type]" value="praise" checked={@feedback_type == "praise"}>
            Praise
          </label>
          <label>
            <input type="radio" name="feedback[type]" value="suggestion" checked={@feedback_type == "suggestion"}>
            Suggestion
          </label>
          <label>
            <input type="radio" name="feedback[type]" value="concern" checked={@feedback_type == "concern"}>
            Concern
          </label>
        </div>
        <textarea name="feedback[content]" placeholder="Your feedback here..." required></textarea>
        <button type="submit">Submit Feedback</button>
      </form>
    </div>
    """
  end
end