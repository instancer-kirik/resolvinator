defmodule Resolvinator.ResourcesTest do
  use Resolvinator.DataCase

  alias Resolvinator.Resources

  describe "resources" do
    alias Resolvinator.Resources.Resource

    import Resolvinator.ResourcesFixtures

    @invalid_attrs %{name: nil, type: nil, unit: nil, description: nil, metadata: nil, quantity: nil, cost_per_unit: nil, availability_status: nil}

    test "list_resources/0 returns all resources" do
      resource = resource_fixture()
      assert Resources.list_resources() == [resource]
    end

    test "get_resource!/1 returns the resource with given id" do
      resource = resource_fixture()
      assert Resources.get_resource!(resource.id) == resource
    end

    test "create_resource/1 with valid data creates a resource" do
      valid_attrs = %{name: "some name", type: "some type", unit: "some unit", description: "some description", metadata: %{}, quantity: "120.5", cost_per_unit: "120.5", availability_status: "some availability_status"}

      assert {:ok, %Resource{} = resource} = Resources.create_resource(valid_attrs)
      assert resource.name == "some name"
      assert resource.type == "some type"
      assert resource.unit == "some unit"
      assert resource.description == "some description"
      assert resource.metadata == %{}
      assert resource.quantity == Decimal.new("120.5")
      assert resource.cost_per_unit == Decimal.new("120.5")
      assert resource.availability_status == "some availability_status"
    end

    test "create_resource/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_resource(@invalid_attrs)
    end

    test "update_resource/2 with valid data updates the resource" do
      resource = resource_fixture()
      update_attrs = %{name: "some updated name", type: "some updated type", unit: "some updated unit", description: "some updated description", metadata: %{}, quantity: "456.7", cost_per_unit: "456.7", availability_status: "some updated availability_status"}

      assert {:ok, %Resource{} = resource} = Resources.update_resource(resource, update_attrs)
      assert resource.name == "some updated name"
      assert resource.type == "some updated type"
      assert resource.unit == "some updated unit"
      assert resource.description == "some updated description"
      assert resource.metadata == %{}
      assert resource.quantity == Decimal.new("456.7")
      assert resource.cost_per_unit == Decimal.new("456.7")
      assert resource.availability_status == "some updated availability_status"
    end

    test "update_resource/2 with invalid data returns error changeset" do
      resource = resource_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_resource(resource, @invalid_attrs)
      assert resource == Resources.get_resource!(resource.id)
    end

    test "delete_resource/1 deletes the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{}} = Resources.delete_resource(resource)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_resource!(resource.id) end
    end

    test "change_resource/1 returns a resource changeset" do
      resource = resource_fixture()
      assert %Ecto.Changeset{} = Resources.change_resource(resource)
    end
  end
end
