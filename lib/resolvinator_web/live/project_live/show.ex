defmodule ResolvinatorWeb.ProjectLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Projects
  alias Resolvinator.Accounts
  alias Resolvinator.Blockchain.ProjectToken

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    
    {:ok,
     socket
     |> assign(:current_user_id, current_user.id)
     |> assign(:show_stake_modal, false)
     |> assign(:show_transfer_modal, false)
     |> assign(:selected_token_id, nil)
     |> assign(:token_input, "")}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    project = Projects.get_project!(id)
    tokens = ProjectToken.list_user_tokens(socket.assigns.current_user_id)
             |> Enum.filter(&(&1.project_id == project.id))
    
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:project, project)
     |> assign(:tokens, tokens)}
  end

  @impl true
  def handle_event("mint-nft", _, socket) do
    case ProjectToken.mint_nft(socket.assigns.project, socket.assigns.current_user_id) do
      {:ok, token} ->
        {:noreply,
         socket
         |> put_flash(:info, "NFT minted successfully.")
         |> update(:tokens, &[token | &1])}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error minting NFT.")}
    end
  end

  def handle_event("mint-governance-tokens", %{"amount" => amount}, socket) do
    {amount, _} = Decimal.parse(amount)
    
    case ProjectToken.mint_governance_tokens(
      socket.assigns.project,
      socket.assigns.current_user_id,
      amount
    ) do
      {:ok, token} ->
        {:noreply,
         socket
         |> put_flash(:info, "Governance tokens minted successfully.")
         |> update(:tokens, &[token | &1])}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error minting governance tokens.")}
    end
  end

  def handle_event("show-stake-modal", %{"token-id" => token_id}, socket) do
    {:noreply,
     socket
     |> assign(:show_stake_modal, true)
     |> assign(:selected_token_id, token_id)}
  end

  def handle_event("hide-stake-modal", _, socket) do
    {:noreply,
     socket
     |> assign(:show_stake_modal, false)
     |> assign(:selected_token_id, nil)}
  end

  def handle_event("show-transfer-modal", %{"token-id" => token_id}, socket) do
    {:noreply,
     socket
     |> assign(:show_transfer_modal, true)
     |> assign(:selected_token_id, token_id)}
  end

  def handle_event("hide-transfer-modal", _, socket) do
    {:noreply,
     socket
     |> assign(:show_transfer_modal, false)
     |> assign(:selected_token_id, nil)}
  end

  def handle_event("stake-tokens", %{"token_id" => token_id, "amount" => amount, "duration" => duration}, socket) do
    token = Enum.find(socket.assigns.tokens, &(&1.id == token_id))
    {amount, _} = Decimal.parse(amount)
    {duration, _} = Integer.parse(duration)

    case ProjectToken.stake_tokens(token, amount, duration) do
      {:ok, updated_token} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tokens staked successfully.")
         |> assign(:show_stake_modal, false)
         |> assign(:selected_token_id, nil)
         |> update(:tokens, fn tokens ->
           Enum.map(tokens, fn t -> if t.id == token_id, do: updated_token, else: t end)
         end)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error staking tokens.")}
    end
  end

  def handle_event("transfer-token", %{"token_id" => token_id, "email" => email}, socket) do
    token = Enum.find(socket.assigns.tokens, &(&1.id == token_id))
    
    with {:ok, recipient} <- Accounts.get_user_by_email(email),
         {:ok, _token} <- ProjectToken.transfer(token, recipient) do
      {:noreply,
       socket
       |> put_flash(:info, "Token transferred successfully.")
       |> assign(:show_transfer_modal, false)
       |> assign(:selected_token_id, nil)
       |> update(:tokens, &Enum.reject(&1, fn t -> t.id == token_id end))}
    else
      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Recipient not found.")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error transferring token.")}
    end
  end

  defp page_title(:show), do: "Show Project"
  defp page_title(:edit), do: "Edit Project"
end
