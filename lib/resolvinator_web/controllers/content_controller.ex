defmodule ResolvinatorWeb.ContentController do
  use ResolvinatorWeb, :controller
  alias Resolvinator.Content
  
  # Import authentication functions
  import ResolvinatorWeb.AuthHelpers, only: [is_authenticated?: 1]

  # Add this plug to ensure current_user is assigned
  plug :fetch_current_user when action in [:show]

  def show(conn, %{"id" => id}) do
    content = Content.get_content!(id)

    # Different delivery methods based on user/session
    cond do
      is_bot?(conn) ->
        render(conn, :show, content: redacted_content(content))

      is_authenticated?(conn) ->
        render(conn, :show, content: content)

      true ->
        render(conn, :show, content: protected_content(content))
    end
  end

  defp is_bot?(conn) do
    user_agent = get_req_header(conn, "user-agent") |> List.first()
    # Check against known bot patterns
    Regex.match?(~r/bot|crawler|spider|crawling/i, user_agent)
  end

  defp redacted_content(content) do
    # Remove sensitive information for bots
    %{content |
      metadata: %{},
      sensitive_data: nil,
      text: redact_sensitive_text(content.text)
    }
  end

  defp protected_content(content) do
    # Apply protection methods based on content type
    %{content |
      text: generate_protected_text(content.text),
      sensitive_data: nil,
      metadata: filter_metadata(content.metadata)
    }
  end

  defp generate_protected_text(text) when is_binary(text) do
    # Example: Show first paragraph and blur/hide the rest
    case String.split(text, "\n\n", parts: 2) do
      [first | _rest] -> "#{first}\n\n[Protected Content - Please Sign In to View]"
      [] -> "[Protected Content - Please Sign In to View]"
    end
  end
  defp generate_protected_text(_), do: "[Protected Content - Please Sign In to View]"

  defp redact_sensitive_text(text) when is_binary(text) do
    # Example: Replace potentially sensitive information with [REDACTED]
    text
    |> String.replace(~r/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i, "[EMAIL REDACTED]")
    |> String.replace(~r/\b\d{3}[-.]?\d{3}[-.]?\d{4}\b/, "[PHONE REDACTED]")
    |> String.replace(~r/\b\d{16}\b/, "[CARD NUMBER REDACTED]")
  end
  defp redact_sensitive_text(_), do: "[REDACTED]"

  defp filter_metadata(metadata) when is_map(metadata) do
    # Only keep safe, public metadata fields
    allowed_keys = ~w(created_at updated_at category tags)
    Map.take(metadata, allowed_keys)
  end
  defp filter_metadata(_), do: %{}

  defp fetch_current_user(conn, _opts) do
    ResolvinatorWeb.UserAuth.fetch_current_user(conn, [])
  end
end
