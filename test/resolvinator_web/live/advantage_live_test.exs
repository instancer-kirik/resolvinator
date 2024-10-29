defmodule ResolvinatorWeb.AdvantageLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.ContentFixtures

  @create_attrs %{name: "some name", desc: "some desc", upvotes: 42, downvotes: 42}
  @update_attrs %{name: "some updated name", desc: "some updated desc", upvotes: 43, downvotes: 43}
  @invalid_attrs %{name: nil, desc: nil, upvotes: nil, downvotes: nil}

  defp create_advantage(_) do
    advantage = advantage_fixture()
    %{advantage: advantage}
  end

  describe "Index" do
    setup [:create_advantage]

    test "lists all advantages", %{conn: conn, advantage: advantage} do
      {:ok, _index_live, html} = live(conn, ~p"/advantages")

      assert html =~ "Listing Advantages"
      assert html =~ advantage.name
    end

    test "saves new advantage", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/advantages")

      assert index_live |> element("a", "New Advantage") |> render_click() =~
               "New Advantage"

      assert_patch(index_live, ~p"/advantages/new")

      assert index_live
             |> form("#advantage-form", advantage: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#advantage-form", advantage: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/advantages")

      html = render(index_live)
      assert html =~ "Advantage created successfully"
      assert html =~ "some name"
    end

    test "updates advantage in listing", %{conn: conn, advantage: advantage} do
      {:ok, index_live, _html} = live(conn, ~p"/advantages")

      assert index_live |> element("#advantages-#{advantage.id} a", "Edit") |> render_click() =~
               "Edit Advantage"

      assert_patch(index_live, ~p"/advantages/#{advantage}/edit")

      assert index_live
             |> form("#advantage-form", advantage: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#advantage-form", advantage: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/advantages")

      html = render(index_live)
      assert html =~ "Advantage updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes advantage in listing", %{conn: conn, advantage: advantage} do
      {:ok, index_live, _html} = live(conn, ~p"/advantages")

      assert index_live |> element("#advantages-#{advantage.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#advantages-#{advantage.id}")
    end
  end

  describe "Show" do
    setup [:create_advantage]

    test "displays advantage", %{conn: conn, advantage: advantage} do
      {:ok, _show_live, html} = live(conn, ~p"/advantages/#{advantage}")

      assert html =~ "Show Advantage"
      assert html =~ advantage.name
    end

    test "updates advantage within modal", %{conn: conn, advantage: advantage} do
      {:ok, show_live, _html} = live(conn, ~p"/advantages/#{advantage}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Advantage"

      assert_patch(show_live, ~p"/advantages/#{advantage}/show/edit")

      assert show_live
             |> form("#advantage-form", advantage: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#advantage-form", advantage: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/advantages/#{advantage}")

      html = render(show_live)
      assert html =~ "Advantage updated successfully"
      assert html =~ "some updated name"
    end
  end
end
