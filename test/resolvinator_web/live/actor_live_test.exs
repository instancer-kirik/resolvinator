defmodule ResolvinatorWeb.ActorLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.ActorsFixtures

  @create_attrs %{name: "some name", status: "some status", type: "some type", description: "some description", role: "some role", influence_level: "some influence_level", contact_info: %{}}
  @update_attrs %{name: "some updated name", status: "some updated status", type: "some updated type", description: "some updated description", role: "some updated role", influence_level: "some updated influence_level", contact_info: %{}}
  @invalid_attrs %{name: nil, status: nil, type: nil, description: nil, role: nil, influence_level: nil, contact_info: nil}

  defp create_actor(_) do
    actor = actor_fixture()
    %{actor: actor}
  end

  describe "Index" do
    setup [:create_actor]

    test "lists all actors", %{conn: conn, actor: actor} do
      {:ok, _index_live, html} = live(conn, ~p"/actors")

      assert html =~ "Listing Actors"
      assert html =~ actor.name
    end

    test "saves new actor", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/actors")

      assert index_live |> element("a", "New Actor") |> render_click() =~
               "New Actor"

      assert_patch(index_live, ~p"/actors/new")

      assert index_live
             |> form("#actor-form", actor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#actor-form", actor: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/actors")

      html = render(index_live)
      assert html =~ "Actor created successfully"
      assert html =~ "some name"
    end

    test "updates actor in listing", %{conn: conn, actor: actor} do
      {:ok, index_live, _html} = live(conn, ~p"/actors")

      assert index_live |> element("#actors-#{actor.id} a", "Edit") |> render_click() =~
               "Edit Actor"

      assert_patch(index_live, ~p"/actors/#{actor}/edit")

      assert index_live
             |> form("#actor-form", actor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#actor-form", actor: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/actors")

      html = render(index_live)
      assert html =~ "Actor updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes actor in listing", %{conn: conn, actor: actor} do
      {:ok, index_live, _html} = live(conn, ~p"/actors")

      assert index_live |> element("#actors-#{actor.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#actors-#{actor.id}")
    end
  end

  describe "Show" do
    setup [:create_actor]

    test "displays actor", %{conn: conn, actor: actor} do
      {:ok, _show_live, html} = live(conn, ~p"/actors/#{actor}")

      assert html =~ "Show Actor"
      assert html =~ actor.name
    end

    test "updates actor within modal", %{conn: conn, actor: actor} do
      {:ok, show_live, _html} = live(conn, ~p"/actors/#{actor}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Actor"

      assert_patch(show_live, ~p"/actors/#{actor}/show/edit")

      assert show_live
             |> form("#actor-form", actor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#actor-form", actor: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/actors/#{actor}")

      html = render(show_live)
      assert html =~ "Actor updated successfully"
      assert html =~ "some updated name"
    end
  end
end
