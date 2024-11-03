defmodule ResolvinatorWeb.ResourceLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.ResourcesFixtures

  @create_attrs %{name: "some name", type: "some type", unit: "some unit", description: "some description", metadata: %{}, quantity: "120.5", cost_per_unit: "120.5", availability_status: "some availability_status"}
  @update_attrs %{name: "some updated name", type: "some updated type", unit: "some updated unit", description: "some updated description", metadata: %{}, quantity: "456.7", cost_per_unit: "456.7", availability_status: "some updated availability_status"}
  @invalid_attrs %{name: nil, type: nil, unit: nil, description: nil, metadata: nil, quantity: nil, cost_per_unit: nil, availability_status: nil}

  defp create_resource(_) do
    resource = resource_fixture()
    %{resource: resource}
  end

  describe "Index" do
    setup [:create_resource]

    test "lists all resources", %{conn: conn, resource: resource} do
      {:ok, _index_live, html} = live(conn, ~p"/resources")

      assert html =~ "Listing Resources"
      assert html =~ resource.name
    end

    test "saves new resource", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert index_live |> element("a", "New Resource") |> render_click() =~
               "New Resource"

      assert_patch(index_live, ~p"/resources/new")

      assert index_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#resource-form", resource: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/resources")

      html = render(index_live)
      assert html =~ "Resource created successfully"
      assert html =~ "some name"
    end

    test "updates resource in listing", %{conn: conn, resource: resource} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert index_live |> element("#resources-#{resource.id} a", "Edit") |> render_click() =~
               "Edit Resource"

      assert_patch(index_live, ~p"/resources/#{resource}/edit")

      assert index_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#resource-form", resource: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/resources")

      html = render(index_live)
      assert html =~ "Resource updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes resource in listing", %{conn: conn, resource: resource} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert index_live |> element("#resources-#{resource.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#resources-#{resource.id}")
    end
  end

  describe "Show" do
    setup [:create_resource]

    test "displays resource", %{conn: conn, resource: resource} do
      {:ok, _show_live, html} = live(conn, ~p"/resources/#{resource}")

      assert html =~ "Show Resource"
      assert html =~ resource.name
    end

    test "updates resource within modal", %{conn: conn, resource: resource} do
      {:ok, show_live, _html} = live(conn, ~p"/resources/#{resource}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Resource"

      assert_patch(show_live, ~p"/resources/#{resource}/show/edit")

      assert show_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#resource-form", resource: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/resources/#{resource}")

      html = render(show_live)
      assert html =~ "Resource updated successfully"
      assert html =~ "some updated name"
    end
  end
end
