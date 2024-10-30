defmodule ResolvinatorWeb.MitigationTaskLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.RisksFixtures

  @create_attrs %{name: "some name", status: "some status", description: "some description", due_date: "2024-10-29", completion_date: "2024-10-29"}
  @update_attrs %{name: "some updated name", status: "some updated status", description: "some updated description", due_date: "2024-10-30", completion_date: "2024-10-30"}
  @invalid_attrs %{name: nil, status: nil, description: nil, due_date: nil, completion_date: nil}

  defp create_mitigation_task(_) do
    mitigation_task = mitigation_task_fixture()
    %{mitigation_task: mitigation_task}
  end

  describe "Index" do
    setup [:create_mitigation_task]

    test "lists all mitigation_tasks", %{conn: conn, mitigation_task: mitigation_task} do
      {:ok, _index_live, html} = live(conn, ~p"/mitigation_tasks")

      assert html =~ "Listing Mitigation tasks"
      assert html =~ mitigation_task.name
    end

    test "saves new mitigation_task", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mitigation_tasks")

      assert index_live |> element("a", "New Mitigation task") |> render_click() =~
               "New Mitigation task"

      assert_patch(index_live, ~p"/mitigation_tasks/new")

      assert index_live
             |> form("#mitigation_task-form", mitigation_task: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mitigation_task-form", mitigation_task: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mitigation_tasks")

      html = render(index_live)
      assert html =~ "Mitigation task created successfully"
      assert html =~ "some name"
    end

    test "updates mitigation_task in listing", %{conn: conn, mitigation_task: mitigation_task} do
      {:ok, index_live, _html} = live(conn, ~p"/mitigation_tasks")

      assert index_live |> element("#mitigation_tasks-#{mitigation_task.id} a", "Edit") |> render_click() =~
               "Edit Mitigation task"

      assert_patch(index_live, ~p"/mitigation_tasks/#{mitigation_task}/edit")

      assert index_live
             |> form("#mitigation_task-form", mitigation_task: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mitigation_task-form", mitigation_task: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mitigation_tasks")

      html = render(index_live)
      assert html =~ "Mitigation task updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes mitigation_task in listing", %{conn: conn, mitigation_task: mitigation_task} do
      {:ok, index_live, _html} = live(conn, ~p"/mitigation_tasks")

      assert index_live |> element("#mitigation_tasks-#{mitigation_task.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mitigation_tasks-#{mitigation_task.id}")
    end
  end

  describe "Show" do
    setup [:create_mitigation_task]

    test "displays mitigation_task", %{conn: conn, mitigation_task: mitigation_task} do
      {:ok, _show_live, html} = live(conn, ~p"/mitigation_tasks/#{mitigation_task}")

      assert html =~ "Show Mitigation task"
      assert html =~ mitigation_task.name
    end

    test "updates mitigation_task within modal", %{conn: conn, mitigation_task: mitigation_task} do
      {:ok, show_live, _html} = live(conn, ~p"/mitigation_tasks/#{mitigation_task}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Mitigation task"

      assert_patch(show_live, ~p"/mitigation_tasks/#{mitigation_task}/show/edit")

      assert show_live
             |> form("#mitigation_task-form", mitigation_task: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#mitigation_task-form", mitigation_task: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/mitigation_tasks/#{mitigation_task}")

      html = render(show_live)
      assert html =~ "Mitigation task updated successfully"
      assert html =~ "some updated name"
    end
  end
end
