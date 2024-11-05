defmodule ResolvinatorWeb.RiskLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Risks
  alias Resolvinator.AI.FabricAnalysis

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:loading_analysis, false)
     |> assign(:ai_analysis, nil)
     |> assign(:ai_conversation, [])
     |> assign(:ai_form, to_form(%{"question" => ""}))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    risk = Risks.get_risk!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:risk, risk)
     |> load_ai_analysis()}
  end

  @impl true
  def handle_event("ask_ai", %{"question" => question}, socket) do
    risk = socket.assigns.risk

    case FabricAnalysis.get_risk_advice(risk, question) do
      {:ok, answer} ->
        conversation = [{question, answer} | socket.assigns.ai_conversation]
        {:noreply,
         socket
         |> assign(:ai_conversation, conversation)
         |> assign(:ai_form, to_form(%{"question" => ""}))}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to get AI response. Please try again.")}
    end
  end

  defp load_ai_analysis(socket) do
    risk = socket.assigns.risk

    socket
    |> assign(:loading_analysis, true)
    |> start_async(:load_analysis, fn ->
      FabricAnalysis.analyze_risk(risk)
    end)
  end

  @impl true
  def handle_async(:load_analysis, {:ok, analysis}, socket) do
    {:noreply,
     socket
     |> assign(:loading_analysis, false)
     |> assign(:ai_analysis, analysis)}
  end

  @impl true
  def handle_async(:load_analysis, {:error, _reason}, socket) do
    {:noreply,
     socket
     |> assign(:loading_analysis, false)
     |> assign(:ai_analysis, "Failed to load AI analysis. Please try again.")
     |> put_flash(:error, "Failed to load AI analysis")}
  end

  defp page_title(:show), do: "Show Risk"
  defp page_title(:edit), do: "Edit Risk"
end
