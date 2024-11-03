defmodule Resolvinator.RequirementsTest do
  use Resolvinator.DataCase

  alias Resolvinator.Requirements

  describe "requirements" do
    alias Resolvinator.Requirements.Requirement

    import Resolvinator.RequirementsFixtures

    @invalid_attrs %{name: nil, priority: nil, status: nil, type: nil, description: nil, validation_criteria: nil, due_date: nil}

    test "list_requirements/0 returns all requirements" do
      requirement = requirement_fixture()
      assert Requirements.list_requirements() == [requirement]
    end

    test "get_requirement!/1 returns the requirement with given id" do
      requirement = requirement_fixture()
      assert Requirements.get_requirement!(requirement.id) == requirement
    end

    test "create_requirement/1 with valid data creates a requirement" do
      valid_attrs = %{name: "some name", priority: "some priority", status: "some status", type: "some type", description: "some description", validation_criteria: "some validation_criteria", due_date: ~D[2024-11-02]}

      assert {:ok, %Requirement{} = requirement} = Requirements.create_requirement(valid_attrs)
      assert requirement.name == "some name"
      assert requirement.priority == "some priority"
      assert requirement.status == "some status"
      assert requirement.type == "some type"
      assert requirement.description == "some description"
      assert requirement.validation_criteria == "some validation_criteria"
      assert requirement.due_date == ~D[2024-11-02]
    end

    test "create_requirement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Requirements.create_requirement(@invalid_attrs)
    end

    test "update_requirement/2 with valid data updates the requirement" do
      requirement = requirement_fixture()
      update_attrs = %{name: "some updated name", priority: "some updated priority", status: "some updated status", type: "some updated type", description: "some updated description", validation_criteria: "some updated validation_criteria", due_date: ~D[2024-11-03]}

      assert {:ok, %Requirement{} = requirement} = Requirements.update_requirement(requirement, update_attrs)
      assert requirement.name == "some updated name"
      assert requirement.priority == "some updated priority"
      assert requirement.status == "some updated status"
      assert requirement.type == "some updated type"
      assert requirement.description == "some updated description"
      assert requirement.validation_criteria == "some updated validation_criteria"
      assert requirement.due_date == ~D[2024-11-03]
    end

    test "update_requirement/2 with invalid data returns error changeset" do
      requirement = requirement_fixture()
      assert {:error, %Ecto.Changeset{}} = Requirements.update_requirement(requirement, @invalid_attrs)
      assert requirement == Requirements.get_requirement!(requirement.id)
    end

    test "delete_requirement/1 deletes the requirement" do
      requirement = requirement_fixture()
      assert {:ok, %Requirement{}} = Requirements.delete_requirement(requirement)
      assert_raise Ecto.NoResultsError, fn -> Requirements.get_requirement!(requirement.id) end
    end

    test "change_requirement/1 returns a requirement changeset" do
      requirement = requirement_fixture()
      assert %Ecto.Changeset{} = Requirements.change_requirement(requirement)
    end
  end
end
