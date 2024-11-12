defmodule ResolvinatorWeb.ContentController do
  use ResolvinatorWeb, :controller
  alias Resolvinator.Content
  
  import ResolvinatorWeb.AuthHelpers, only: [is_authenticated?: 1]

  # Add more actions that need user data
  plug :fetch_current_user when action in [:show, :edit, :update]

  def show(conn, %{"id" => id}) do
    content = Content.get_content!(id)

    cond do
      is_bot?(conn) ->
        conn
        |> put_resp_header("x-robots-tag", "noindex, nofollow")
        |> render(:show, content: redacted_content(content))

      is_authenticated?(conn) ->
        current_user = conn.assigns.current_user
        if can_access_content?(current_user, content) do
          render(conn, :show, content: content)
        else
          conn
          |> put_status(:forbidden)
          |> render(:forbidden, content: protected_content(content))
        end

      true ->
        conn
        |> put_flash(:info, "Sign in to view full content")
        |> render(:show, content: protected_content(content))
    end
  end

  defp is_bot?(conn) do
    user_agent = get_req_header(conn, "user-agent") |> List.first() || ""
    # Extended bot detection
    bot_patterns = [
      ~r/bot|crawler|spider|crawling/i,
      ~r/googlebot|bingbot|yandex|baiduspider/i,
      ~r/slurp|duckduckbot|facebookexternalhit/i
    ]
    
    Enum.any?(bot_patterns, &Regex.match?(&1, user_agent))
  end

  defp redacted_content(content) do
    # More comprehensive redaction
    %{content |
      metadata: %{},
      sensitive_data: nil,
      text: redact_sensitive_text(content.text),
      tags: content.tags,  # Keep tags for SEO
      title: content.title,  # Keep title for SEO
      created_at: content.created_at  # Keep timestamp for SEO
    }
  end

  defp protected_content(content) do
    # More sophisticated protection
    %{content |
      text: generate_protected_text(content.text),
      sensitive_data: nil,
      metadata: filter_metadata(content.metadata),
      preview_available: content_has_preview?(content),
      auth_required: true
    }
  end

  defp generate_protected_text(text) when is_binary(text) do
    # Enhanced preview generation
    word_limit = 50
    
    text
    |> String.split(~r/\s+/)
    |> Enum.take(word_limit)
    |> Enum.join(" ")
    |> then(&(&1 <> "\n\n[Protected Content - Please Sign In to View Full Content]"))
  end
  defp generate_protected_text(_), do: "[Protected Content - Please Sign In to View]"

  defp redact_sensitive_text(text) when is_binary(text) do
    text
    |> String.replace(~r/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i, "[EMAIL REDACTED]")
    |> String.replace(~r/\b\d{3}[-.]?\d{3}[-.]?\d{4}\b/, "[PHONE REDACTED]")
    |> String.replace(~r/\b\d{16}\b/, "[CARD NUMBER REDACTED]")
    |> String.replace(~r/\b(password|secret|key|token)[:=]\s*\S+/i, "[CREDENTIALS REDACTED]")
    |> String.replace(~r/\b(ssh-rsa|ssh-dss|BEGIN\s+[A-Z\s]+PRIVATE)\s+\S+/i, "[KEY REDACTED]")
  end
  defp redact_sensitive_text(_), do: "[REDACTED]"

  defp filter_metadata(metadata) when is_map(metadata) do
    allowed_keys = ~w(created_at updated_at category tags public_stats view_count)
    Map.take(metadata, allowed_keys)
  end
  defp filter_metadata(_), do: %{}

  defp can_access_content?(user, content) do
    # Add your content access logic here
    cond do
      user.is_admin -> true
      content.visibility == "public" -> true
      content.creator_id == user.id -> true
      content.project_id in user.project_ids -> true
      true -> false
    end
  end

  defp content_has_preview?(content) do
    # Define which content types can have previews
    content.type in ~w(article blog_post documentation)
  end

  defp fetch_current_user(conn, _opts) do
    ResolvinatorWeb.UserAuth.fetch_current_user(conn, [])
  end
end
