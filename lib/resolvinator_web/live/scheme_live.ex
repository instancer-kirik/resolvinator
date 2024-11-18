defmodule ComputinatorWeb.SchemeLive do
	use ComputinatorWeb, :live_view
	alias Phoenix.PubSub

	@topic "scheme"

	def mount(_params, _session, socket) do
		if connected?(socket) do
			PubSub.subscribe(Computinator.PubSub, @topic)
		end

		{:ok,
		 assign(socket,
			 nodes: %{},
			 selected_nodes: [],
			 connecting_mode: false,
			 connecting_from: nil
		 )}
	end

	def handle_event("add_node", %{"content" => content}, socket) do
		node = %{
			id: UUID.uuid4(),
			content: content,
			position: %{x: 100, y: 100},
			type: "idea",
			connections: [],
			metadata: %{}
		}

		PubSub.broadcast(Computinator.PubSub, @topic, {:node_created, node})

		{:noreply, update(socket, :nodes, &Map.put(&1, node.id, node))}
	end

	def handle_event("move_node", %{"id" => id, "x" => x, "y" => y}, socket) do
		PubSub.broadcast(Computinator.PubSub, @topic, {:node_moved, id, %{x: x, y: y}})

		{:noreply,
		 update(socket, :nodes, fn nodes ->
			 put_in(nodes[id].position, %{x: x, y: y})
		 end)}
	end

	def handle_event("connect_nodes", %{"source" => source_id, "target" => target_id}, socket) do
		PubSub.broadcast(Computinator.PubSub, @topic, {:nodes_connected, source_id, target_id})

		{:noreply,
		 update(socket, :nodes, fn nodes ->
			 nodes
			 |> update_in([source_id, :connections], &[target_id | &1])
			 |> update_in([target_id, :connections], &[source_id | &1])
		 end)}
	end

	def handle_info({:node_created, node}, socket) do
		{:noreply, update(socket, :nodes, &Map.put(&1, node.id, node))}
	end

	def handle_info({:node_moved, id, position}, socket) do
		{:noreply,
		 update(socket, :nodes, fn nodes ->
			 put_in(nodes[id].position, position)
		 end)}
	end

	def handle_info({:nodes_connected, source_id, target_id}, socket) do
		{:noreply,
		 update(socket, :nodes, fn nodes ->
			 nodes
			 |> update_in([source_id, :connections], &[target_id | &1])
			 |> update_in([target_id, :connections], &[source_id | &1])
		 end)}
	end

	def render(assigns) do
		~H"""
		<div class="scheme-container">
			<div class="toolbar">
				<button phx-click="show_add_modal">Add Idea</button>
				<button phx-click="toggle_connect_mode">
					<%= if @connecting_mode, do: "Cancel Connection", else: "Connect Ideas" %>
				</button>
				<button phx-click="export">Export</button>
			</div>

			<div class="canvas" 
					 phx-hook="SchemeCanvas"
					 id="scheme-canvas">
				<%= for {id, node} <- @nodes do %>
					<div class="node" 
							 id={"node-#{id}"}
							 data-id={id}
							 style={"left: #{node.position.x}px; top: #{node.position.y}px"}
							 phx-click={
								 if @connecting_mode do
									 "select_node"
								 end
							 }>
						<div class="content"><%= node.content %></div>
					</div>
				<% end %>

				<%= for {_id, node} <- @nodes, target_id <- node.connections do %>
					<svg class="connection">
						<line x1={node.position.x} 
									y1={node.position.y}
									x2={@nodes[target_id].position.x}
									y2={@nodes[target_id].position.y}
									stroke="#88C0D0"
									stroke-width="2" />
					</svg>
				<% end %>
			</div>
		</div>
		"""
	end
end