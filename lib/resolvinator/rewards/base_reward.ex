defmodule Resolvinator.Rewards.BaseReward do
  @moduledoc """
  Base implementation of common reward functionality
  """

  defstruct [:id, :description, :value, :status]

  @type t :: %__MODULE__{
    id: binary(),
    description: String.t(),
    value: float(),
    status: atom()
  }

  def new(id, description) do
    %__MODULE__{
      id: id,
      description: description,
      value: 0.0,
      status: :pending
    }
  end

  def from_map(data) when is_map(data) do
    %__MODULE__{
      id: Map.get(data, "id"),
      description: Map.get(data, "description", ""),
      value: Map.get(data, "value", 0.0),
      status: String.to_existing_atom(Map.get(data, "status", "pending"))
    }
  end

  def to_map(%__MODULE__{} = reward) do
    %{
      "id" => reward.id,
      "description" => reward.description,
      "value" => reward.value,
      "status" => Atom.to_string(reward.status)
    }
  end
end
