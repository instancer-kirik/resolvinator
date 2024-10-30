defmodule Resolvinator.ProjectsTest do
  use Resolvinator.DataCase

  alias Resolvinator.Projects

  describe "projects" do
    alias Resolvinator.Projects.Project

    import Resolvinator.ProjectsFixtures

    @invalid_attrs %{name: nil, status: nil, description: nil, risk_appetite: nil, start_date: nil, target_date: nil, completion_date: nil, settings: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{name: "some name", status: "some status", description: "some description", risk_appetite: "some risk_appetite", start_date: ~D[2024-10-29], target_date: ~D[2024-10-29], completion_date: ~D[2024-10-29], settings: %{}}

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.name == "some name"
      assert project.status == "some status"
      assert project.description == "some description"
      assert project.risk_appetite == "some risk_appetite"
      assert project.start_date == ~D[2024-10-29]
      assert project.target_date == ~D[2024-10-29]
      assert project.completion_date == ~D[2024-10-29]
      assert project.settings == %{}
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", description: "some updated description", risk_appetite: "some updated risk_appetite", start_date: ~D[2024-10-30], target_date: ~D[2024-10-30], completion_date: ~D[2024-10-30], settings: %{}}

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.name == "some updated name"
      assert project.status == "some updated status"
      assert project.description == "some updated description"
      assert project.risk_appetite == "some updated risk_appetite"
      assert project.start_date == ~D[2024-10-30]
      assert project.target_date == ~D[2024-10-30]
      assert project.completion_date == ~D[2024-10-30]
      assert project.settings == %{}
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end
