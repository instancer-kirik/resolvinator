defmodule ResolvinatorWeb.RequirementLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.RequirementsFixtures

  @create_attrs %{name: "some name", priority: "some priority", status: "some status", type: "some type", description: "some description", validation_criteria: "some validation_criteria", due_date: "2024-11-02"}
  @update_attrs %{name: "some updated name", priority: "some updated priority", status: "some updated status", type: "some updated type", description: "some updated description", validation_criteria: "some updated validation_criteria", due_date: "2024-11-03"}
  @invalid_attrs %{name: nil, priority: nil, status: nil, type: nil, description: nil, validation_criteria: nil, due_date: nil}

  defp create_requirement(_) do
    requirement = requirement_fixture()
    %{requirement: requirement}
  end

  describe "Index" do
    setup [:create_requirement]

    test "lists all requirements", %{conn: conn, requirement: requirement} do
      {:ok, _index_live, html} = live(conn, ~p"/requirements")

      assert html =~ "Listing Requirements"
      assert html =~ requirement.name
    end

    test "saves new requirement", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/requirements")

      assert index_live |> element("a", "New Requirement") |> render_click() =~
               "New Requirement"

      assert_patch(index_live, ~p"/requirements/new")

      assert index_live
             |> form("#requirement-form", requirement: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#requirement-form", requirement: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/requirements")

      html = render(index_live)
      assert html =~ "Requirement created successfully"
      assert html =~ "some name"
    end

    test "updates requirement in listing", %{conn: conn, requirement: requirement} do
      {:ok, index_live, _html} = live(conn, ~p"/requirements")

      assert index_live |> element("#requirements-#{requirement.id} a", "Edit") |> render_click() =~
               "Edit Requirement"

      assert_patch(index_live, ~p"/requirements/#{requirement}/edit")

      assert index_live
             |> form("#requirement-form", requirement: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#requirement-form", requirement: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/requirements")

      html = render(index_live)
      assert html =~ "Requirement updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes requirement in listing", %{conn: conn, requirement: requirement} do
      {:ok, index_live, _html} = live(conn, ~p"/requirements")

      assert index_live |> element("#requirements-#{requirement.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#requirements-#{requirement.id}")
    end
  end

  describe "Show" do
    setup [:create_requirement]

    test "displays requirement", %{conn: conn, requirement: requirement} do
      {:ok, _show_live, html} = live(conn, ~p"/requirements/#{requirement}")

      assert html =~ "Show Requirement"
      assert html =~ requirement.name
    end

    test "updates requirement within modal", %{conn: conn, requirement: requirement} do
      {:ok, show_live, _html} = live(conn, ~p"/requirements/#{requirement}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Requirement"

      assert_patch(show_live, ~p"/requirements/#{requirement}/show/edit")

      assert show_live
             |> form("#requirement-form", requirement: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#requirement-form", requirement: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/requirements/#{requirement}")

      html = render(show_live)
      assert html =~ "Requirement updated successfully"
      assert html =~ "some updated name"
    end
  end
end
