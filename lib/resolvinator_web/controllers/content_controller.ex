defmodule ResolvinatorWeb.ContentController do
  use ResolvinatorWeb, :controller

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

  defp protected_content(content) do
    # Apply protection methods based on content type
    %{content |
      text: generate_protected_text(content.text),
      sensitive_data: nil
    }
  end
end
