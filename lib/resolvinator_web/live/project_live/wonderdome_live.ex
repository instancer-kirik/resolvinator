defmodule ResolvinatorWeb.WonderdomeLive do
  use ResolvinatorWeb, :live_view
  alias Resolvinator.Wonderdome

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Resolvinator.PubSub, "wonderdome")
    end

    {:ok, assign(socket, battles: list_active_battles())}
  end

  @impl true
  def handle_event("start_battle", _params, socket) do
    case Wonderdome.start_battle() do
      {:ok, battle} ->
        {:noreply, update(socket, :battles, &[battle | &1])}
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to start battle")}
    end
  end

  @impl true
  def handle_event("fire_volley", %{"feedback" => _feedback} = params, socket) do
    case Wonderdome.fire_volley(params) do
      {:ok, _result} ->
        {:noreply, socket}
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to fire volley")}
    end
  end

  defp list_active_battles do
    Wonderdome.list_active_battles()
  end
end