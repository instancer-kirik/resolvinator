defmodule Resolvinator.ActorsTest do
  use Resolvinator.DataCase

  alias Resolvinator.Actors

  describe "actors" do
    alias Resolvinator.Actors.Actor

    import Resolvinator.ActorsFixtures

    @invalid_attrs %{name: nil, status: nil, type: nil, description: nil, role: nil, influence_level: nil, contact_info: nil}

    test "list_actors/0 returns all actors" do
      actor = actor_fixture()
      assert Actors.list_actors() == [actor]
    end

    test "get_actor!/1 returns the actor with given id" do
      actor = actor_fixture()
      assert Actors.get_actor!(actor.id) == actor
    end

    test "create_actor/1 with valid data creates a actor" do
      valid_attrs = %{name: "some name", status: "some status", type: "some type", description: "some description", role: "some role", influence_level: "some influence_level", contact_info: %{}}

      assert {:ok, %Actor{} = actor} = Actors.create_actor(valid_attrs)
      assert actor.name == "some name"
      assert actor.status == "some status"
      assert actor.type == "some type"
      assert actor.description == "some description"
      assert actor.role == "some role"
      assert actor.influence_level == "some influence_level"
      assert actor.contact_info == %{}
    end

    test "create_actor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Actors.create_actor(@invalid_attrs)
    end

    test "update_actor/2 with valid data updates the actor" do
      actor = actor_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", type: "some updated type", description: "some updated description", role: "some updated role", influence_level: "some updated influence_level", contact_info: %{}}

      assert {:ok, %Actor{} = actor} = Actors.update_actor(actor, update_attrs)
      assert actor.name == "some updated name"
      assert actor.status == "some updated status"
      assert actor.type == "some updated type"
      assert actor.description == "some updated description"
      assert actor.role == "some updated role"
      assert actor.influence_level == "some updated influence_level"
      assert actor.contact_info == %{}
    end

    test "update_actor/2 with invalid data returns error changeset" do
      actor = actor_fixture()
      assert {:error, %Ecto.Changeset{}} = Actors.update_actor(actor, @invalid_attrs)
      assert actor == Actors.get_actor!(actor.id)
    end

    test "delete_actor/1 deletes the actor" do
      actor = actor_fixture()
      assert {:ok, %Actor{}} = Actors.delete_actor(actor)
      assert_raise Ecto.NoResultsError, fn -> Actors.get_actor!(actor.id) end
    end

    test "change_actor/1 returns a actor changeset" do
      actor = actor_fixture()
      assert %Ecto.Changeset{} = Actors.change_actor(actor)
    end
  end
end
