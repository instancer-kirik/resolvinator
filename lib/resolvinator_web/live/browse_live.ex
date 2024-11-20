defmodule ResolvinatorWeb.BrowseLive do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Browse
  alias Resolvinator.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:results, %{})
     |> assign(:page, 1)
     |> assign(:loading, false)
     |> assign(:filters, %{})
     |> assign(:selected_type, nil)
     |> assign(:suggestions, [])
     |> assign(:user_content, get_initial_user_content(socket))
     |> assign(:trending_searches, get_trending_searches(socket))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    query = params["q"] || ""
    type = params["type"]
    page = String.to_integer(params["page"] || "1")
    
    socket =
      if query != "" do
        perform_search(socket, query, type, page)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    {:noreply,
     socket
     |> push_patch(to: ~p"/browse?#{%{q: query, page: 1}}")}
  end

  def handle_event("filter", %{"type" => type}, socket) do
    {:noreply,
     socket
     |> push_patch(to: ~p"/browse?#{%{q: socket.assigns.query, type: type, page: 1}}")}
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) >= 2 do
    suggestions = Browse.suggest_search_terms(query, socket.assigns.current_user)
    {:noreply, assign(socket, :suggestions, suggestions)}
  end

  def handle_event("suggest", _, socket) do
    {:noreply, assign(socket, :suggestions, [])}
  end

  def handle_event("load-more", _, socket) do
    next_page = socket.assigns.page + 1
    {:noreply,
     socket
     |> push_patch(to: ~p"/browse?#{%{q: socket.assigns.query, page: next_page}}")}
  end

  defp perform_search(socket, query, type, page) do
    socket = assign(socket, loading: true)

    results =
      if type do
        {:ok, results} = Browse.search_type(type, query, socket.assigns.current_user, page: page)
        %{type => results}
      else
        Browse.faceted_search(query, socket.assigns.current_user,
          types: ["project", "task", "resource", "document"],
          page: page
        )
      end

    socket
    |> assign(:results, results)
    |> assign(:query, query)
    |> assign(:page, page)
    |> assign(:selected_type, type)
    |> assign(:loading, false)
  end

  defp get_initial_user_content(socket) do
    if socket.assigns.current_user do
      Browse.get_user_content(socket.assigns.current_user)
    else
      %{projects: [], tasks: [], resources: []}
    end
  end

  defp get_trending_searches(socket) do
    if socket.assigns.current_user do
      Browse.trending_searches(socket.assigns.current_user)
    else
      []
    end
  end

  defp assign_current_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(session["user_token"])
    end)
  end
end
