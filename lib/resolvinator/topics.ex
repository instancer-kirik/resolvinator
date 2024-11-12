defmodule Resolvinator.Topics do
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Content.Topic

  def get_topic_by_slug(slug) do
    Repo.one(from t in Topic, where: t.slug == ^slug)
  end
end 