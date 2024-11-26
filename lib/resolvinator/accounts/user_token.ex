defmodule Resolvinator.Acts.UserToken do
  @moduledoc """
  This module is deprecated. Use Acts.UserToken instead.
  """

  @deprecated "Use Acts.UserToken instead"
  defdelegate build_session_token(user), to: Acts.UserToken
  @deprecated "Use Acts.UserToken instead"
  defdelegate verify_session_token_query(token), to: Acts.UserToken
  @deprecated "Use Acts.UserToken instead"
  defdelegate token_and_context_query(token, context), to: Acts.UserToken
  @deprecated "Use Acts.UserToken instead"
  defdelegate user_and_contexts_query(user, contexts), to: Acts.UserToken
end
