defmodule ResolvinatorWeb.TopicLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage topic records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="topic-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="space-y-6">
          <%# Basic Info %>
          <div class="space-y-4">
            <.input field={@form[:name]} type="text" label="Name" />
            <.input field={@form[:desc]} type="textarea" label="Description" />
            <.input field={@form[:slug]} type="text" label="Slug" />
          </div>

          <%# Categorization %>
          <div class="grid grid-cols-2 gap-4">
            <.input
              field={@form[:category]}
              type="select"
              label="Category"
              options={~w(core supplementary specialized)}
            />
            <.input
              field={@form[:level]}
              type="select"
              label="Level"
              options={~w(beginner intermediate advanced expert)}
            />
          </div>

          <%# Feature Flags %>
          <div class="space-y-2">
            <h3 class="font-medium">Settings</h3>
            <div class="grid grid-cols-2 gap-4">
              <.input field={@form[:is_featured]} type="checkbox" label="Featured" />
              <.input field={@form[:is_hidden]} type="checkbox" label="Hidden" />
              <.input field={@form[:is_private]} type="checkbox" label="Private" />
              <.input field={@form[:is_age_restricted]} type="checkbox" label="Age Restricted" />
            </div>
          </div>

          <%# Metadata Tabs %>
          <div class="tabs tabs-boxed">
            <%= for {view, label} <- [basic: "Basic", advanced: "Advanced", custom: "Custom"] do %>
              <a class={"tab #{if @metadata_view == view, do: "tab-active"}"}
                 phx-click="toggle-metadata-view"
                 phx-value-view={view}
                 phx-target={@myself}>
                <%= label %>
              </a>
            <% end %>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :metadata_view, :basic)}
  end

  @impl true
  def update(%{topic: topic} = assigns, socket) do
    changeset = Content.change_topic(topic)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"topic" => topic_params}, socket) do
    changeset =
      socket.assigns.topic
      |> Content.change_topic(topic_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"topic" => topic_params}, socket) do
    save_topic(socket, socket.assigns.action, topic_params)
  end

  @impl true
  def handle_event("toggle-metadata-view", %{"view" => view}, socket) do
    {:noreply, assign(socket, :metadata_view, String.to_existing_atom(view))}
  end

  defp save_topic(socket, :edit, topic_params) do
    case Content.update_topic(socket.assigns.topic, topic_params) do
      {:ok, topic} ->
        notify_parent({:saved, topic})
        {:noreply,
         socket
         |> put_flash(:info, "Topic updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_topic(socket, :new, topic_params) do
    case Content.create_topic(topic_params) do
      {:ok, topic} ->
        notify_parent({:saved, topic})
        {:noreply,
         socket
         |> put_flash(:info, "Topic created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end 