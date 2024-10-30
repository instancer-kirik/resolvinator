defmodule Resolvinator.PubSub do
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Resolvinator.PubSub, topic)
  end

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(Resolvinator.PubSub, topic, message)
  end

  def broadcast_from(from_pid, topic, message) do
    Phoenix.PubSub.broadcast_from(Resolvinator.PubSub, from_pid, topic, message)
  end
end 