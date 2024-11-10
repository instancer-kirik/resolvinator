defmodule ResolvinatorWeb.QALive.Browse do
  use ResolvinatorWeb, :live_view
  alias Resolvinator.Content
  alias Resolvinator.AI.FabricAnalysis

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Browse Questions")
     |> assign(:filter_form, to_form(%{
       "subject_area" => "",
       "difficulty" => "",
       "status" => "",
       "has_proof" => "",
       "search" => ""
     }))
     |> assign(:sort_by, "recent")
     |> assign(:view_mode, "list")
     |> assign(:questions, [])
     |> assign(:loading, true)
     |> assign(:page, 1)
     |> assign(:total_pages, 1)
     |> stream(:questions, [])
     |> load_questions()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_params(params)
     |> load_questions()}
  end

  @impl true
  def handle_event("filter", %{"filter" => filter_params}, socket) do
    {:noreply,
     socket
     |> assign(:filter_form, to_form(filter_params))
     |> push_patch(to: ~p"/qa?#{build_params(socket, filter: filter_params)}")}
  end

  @impl true
  def handle_event("sort", %{"sort" => sort_by}, socket) do
    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> push_patch(to: ~p"/qa?#{build_params(socket, sort: sort_by)}")}
  end

  @impl true
  def handle_event("change-view", %{"view" => view_mode}, socket) do
    {:noreply, assign(socket, :view_mode, view_mode)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Questions & Answers</h1>
        <div class="flex space-x-4">
          <.link patch={~p"/qa/new"} class="button-primary">
            Ask Question
          </.link>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <!-- Filters Sidebar -->
        <div class="lg:col-span-1">
          <.form for={@filter_form} phx-change="filter" class="space-y-4">
            <.input
              field={@filter_form[:subject_area]}
              type="select"
              label="Subject Area"
              prompt="All Subjects"
              options={subject_area_options()}
            />

            <.input
              field={@filter_form[:difficulty]}
              type="select"
              label="Difficulty"
              prompt="All Levels"
              options={difficulty_options()}
            />

            <.input
              field={@filter_form[:status]}
              type="select"
              label="Status"
              prompt="All Statuses"
              options={status_options()}
            />

            <.input
              field={@filter_form[:has_proof]}
              type="select"
              label="Proof Type"
              prompt="All Types"
              options={proof_type_options()}
            />

            <.input
              field={@filter_form[:search]}
              type="search"
              label="Search"
              placeholder="Search questions..."
            />
          </.form>

          <div class="mt-6">
            <h3 class="text-sm font-medium text-gray-500 mb-2">Popular Tags</h3>
            <div class="flex flex-wrap gap-2">
              <%= for tag <- popular_tags() do %>
                <.tag name={tag.name} count={tag.count} />
              <% end %>
            </div>
          </div>
        </div>

        <!-- Questions List -->
        <div class="lg:col-span-3">
          <div class="bg-white shadow rounded-lg">
            <!-- Toolbar -->
            <div class="border-b px-4 py-3 flex justify-between items-center">
              <div class="flex space-x-4 items-center">
                <select
                  phx-change="sort"
                  class="form-select text-sm"
                  name="sort"
                >
                  <option value="recent">Most Recent</option>
                  <option value="votes">Most Votes</option>
                  <option value="answers">Most Answers</option>
                  <option value="views">Most Views</option>
                </select>

                <div class="flex space-x-2">
                  <button
                    phx-click="change-view"
                    phx-value-view="list"
                    class={[
                      "p-1 rounded-md",
                      @view_mode == "list" && "bg-gray-100"
                    ]}
                  >
                    <.icon name="hero-list-bullet" class="w-5 h-5" />
                  </button>
                  <button
                    phx-click="change-view"
                    phx-value-view="grid"
                    class={[
                      "p-1 rounded-md",
                      @view_mode == "grid" && "bg-gray-100"
                    ]}
                  >
                    <.icon name="hero-squares-2x2" class="w-5 h-5" />
                  </button>
                </div>
              </div>

              <div class="text-sm text-gray-500">
                Showing <%= @page %> of <%= @total_pages %> pages
              </div>
            </div>

            <!-- Questions -->
            <%= if @view_mode == "list" do %>
              <div id="questions" phx-update="stream" class="divide-y">
                <div :for={{id, question} <- @streams.questions} id={id}>
                  <.question_list_item question={question} />
                </div>
              </div>
            <% else %>
              <div
                id="questions"
                phx-update="stream"
                class="grid grid-cols-2 gap-4 p-4"
              >
                <div :for={{id, question} <- @streams.questions} id={id}>
                  <.question_card question={question} />
                </div>
              </div>
            <% end %>

            <!-- Pagination -->
            <div class="border-t px-4 py-3">
              <.pagination
                page={@page}
                total_pages={@total_pages}
                path={~p"/qa"}
                params={build_params(assigns)}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp question_list_item(assigns) do
    ~H"""
    <div class="p-4 hover:bg-gray-50">
      <div class="flex space-x-4">
        <!-- Stats -->
        <div class="flex flex-col items-center space-y-2 w-16">
          <div class="text-center">
            <div class="text-xl font-medium">
              <%= @question.voting.upvotes - @question.voting.downvotes %>
            </div>
            <div class="text-xs text-gray-500">votes</div>
          </div>
          <div class="text-center">
            <div class={[
              "text-xl font-medium",
              @question.answer_count > 0 && "text-green-600"
            ]}>
              <%= @question.answer_count %>
            </div>
            <div class="text-xs text-gray-500">answers</div>
          </div>
        </div>

        <!-- Content -->
        <div class="flex-1">
          <.link
            navigate={~p"/qa/#{@question}"}
            class="text-lg font-medium text-blue-600 hover:text-blue-800"
          >
            <%= @question.title %>
          </.link>

          <div class="mt-1 text-sm text-gray-600 line-clamp-2">
            <%= @question.desc %>
          </div>

          <div class="mt-2 flex items-center space-x-4">
            <div class="flex flex-wrap gap-2">
              <%= for tag <- @question.tags do %>
                <.tag name={tag} />
              <% end %>
            </div>

            <div class="flex-1"></div>

            <div class="text-sm text-gray-500">
              asked <%= format_time_ago(@question.inserted_at) %> by
              <.link class="text-blue-600 hover:text-blue-800">
                <%= @question.creator.username %>
              </.link>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp question_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg border p-4 hover:shadow-md transition">
      <.link
        navigate={~p"/qa/#{@question}"}
        class="text-lg font-medium text-blue-600 hover:text-blue-800"
      >
        <%= @question.title %>
      </.link>

      <div class="mt-2 text-sm text-gray-600 line-clamp-3">
        <%= @question.desc %>
      </div>

      <div class="mt-4 flex items-center justify-between">
        <div class="flex space-x-4 text-sm text-gray-500">
          <div>
            <span class="font-medium">
              <%= @question.voting.upvotes - @question.voting.downvotes %>
            </span>
            votes
          </div>
          <div>
            <span class={[
              "font-medium",
              @question.answer_count > 0 && "text-green-600"
            ]}>
              <%= @question.answer_count %>
            </span>
            answers
          </div>
        </div>

        <div class="text-sm text-gray-500">
          <%= format_time_ago(@question.inserted_at) %>
        </div>
      </div>

      <div class="mt-3 flex flex-wrap gap-2">
        <%= for tag <- @question.tags do %>
          <.tag name={tag} small />
        <% end %>
      </div>
    </div>
    """
  end

  defp tag(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center rounded-full px-2.5 py-0.5",
      "text-xs font-medium",
      assigns[:count] && "bg-blue-100 text-blue-800",
      !assigns[:count] && "bg-gray-100 text-gray-800",
      assigns[:small] && "text-xs"
    ]}>
      <%= @name %>
      <%= if assigns[:count] do %>
        <span class="ml-1 text-blue-600">
          <%= @count %>
        </span>
      <% end %>
    </span>
    """
  end

  defp load_questions(socket) do
    case Content.list_questions(build_filters(socket), build_options(socket)) do
      {:ok, %{entries: questions, page_number: page, total_pages: total}} ->
        socket
        |> stream(:questions, questions, reset: true)
        |> assign(:page, page)
        |> assign(:total_pages, total)
        |> assign(:loading, false)

      {:error, _reason} ->
        socket
        |> put_flash(:error, "Failed to load questions")
        |> assign(:loading, false)
    end
  end

  defp build_filters(socket) do
    form = socket.assigns.filter_form
    %{
      subject_area: form["subject_area"],
      difficulty: form["difficulty"],
      status: form["status"],
      has_proof: form["has_proof"],
      search: form["search"]
    }
    |> Enum.reject(fn {_k, v} -> v == "" end)
    |> Map.new()
  end

  defp build_options(socket) do
    %{
      sort: socket.assigns.sort_by,
      page: socket.assigns.page,
      per_page: 20
    }
  end

  defp build_params(assigns, overrides \\ %{}) do
    base = %{
      subject_area: assigns.filter_form["subject_area"],
      difficulty: assigns.filter_form["difficulty"],
      status: assigns.filter_form["status"],
      has_proof: assigns.filter_form["has_proof"],
      search: assigns.filter_form["search"],
      sort: assigns.sort_by,
      page: assigns.page
    }

    Map.merge(base, overrides)
    |> Enum.reject(fn {_k, v} -> is_nil(v) or v == "" end)
    |> Map.new()
  end

  defp subject_area_options do
    [
      {"Algebra", "algebra"},
      {"Analysis", "analysis"},
      {"Calculus", "calculus"},
      {"Geometry", "geometry"},
      {"Number Theory", "number_theory"},
      {"Logic", "logic"},
      {"Combinatorics", "combinatorics"},
      {"Probability", "probability"}
    ]
  end

  defp difficulty_options do
    [
      {"Beginner", "beginner"},
      {"Intermediate", "intermediate"},
      {"Advanced", "advanced"},
      {"Expert", "expert"}
    ]
  end

  defp status_options do
    [
      {"Unanswered", "unanswered"},
      {"Answered", "answered"},
      {"Solved", "solved"},
      {"Needs Review", "needs_review"}
    ]
  end

  defp proof_type_options do
    [
      {"Direct Proof", "direct"},
      {"Contradiction", "contradiction"},
      {"Induction", "induction"},
      {"Construction", "construction"},
      {"Visual Proof", "visual"}
    ]
  end

  defp popular_tags do
    [
      %{name: "algebra", count: 120},
      %{name: "calculus", count: 89},
      %{name: "geometry", count: 76},
      %{name: "proofs", count: 65},
      %{name: "linear-algebra", count: 54},
      %{name: "number-theory", count: 43}
    ]
  end

  defp pagination(assigns) do
    ~H"""
    <div class="flex items-center justify-between px-4 py-3 border-t">
      <div class="flex-1 flex justify-between items-center">
        <div>
          <p class="text-sm text-gray-700">
            Showing page <span class="font-medium"><%= @page %></span>
            of <span class="font-medium"><%= @total_pages %></span>
          </p>
        </div>
        <div class="flex space-x-2">
          <.link
            :if={@page > 1}
            patch={~p"/qa?#{build_params(assigns, page: @page - 1)}"}
            class="button-outline"
          >
            Previous
          </.link>
          <.link
            :if={@page < @total_pages}
            patch={~p"/qa?#{build_params(assigns, page: @page + 1)}"}
            class="button-outline"
          >
            Next
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp format_time_ago(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 ->
        "just now"
      diff < 3600 ->
        "#{div(diff, 60)} minutes ago"
      diff < 86400 ->
        "#{div(diff, 3600)} hours ago"
      diff < 2_592_000 ->
        "#{div(diff, 86400)} days ago"
      diff < 31_536_000 ->
        "#{div(diff, 2_592_000)} months ago"
      true ->
        "#{div(diff, 31_536_000)} years ago"
    end
  end

  defp apply_params(socket, params) do
    socket
    |> maybe_apply_filter(params)
    |> maybe_apply_sort(params)
    |> maybe_apply_page(params)
  end

  defp maybe_apply_filter(socket, %{"filter" => filter}) do
    assign(socket, :filter_form, to_form(filter))
  end
  defp maybe_apply_filter(socket, _), do: socket

  defp maybe_apply_sort(socket, %{"sort" => sort}) do
    assign(socket, :sort_by, sort)
  end
  defp maybe_apply_sort(socket, _), do: socket

  defp maybe_apply_page(socket, %{"page" => page}) do
    assign(socket, :page, String.to_integer(page))
  end
  defp maybe_apply_page(socket, _), do: socket
end
