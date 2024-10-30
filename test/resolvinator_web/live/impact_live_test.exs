defmodule ResolvinatorWeb.ImpactLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.RisksFixtures

  @create_attrs %{description: "some description", severity: "some severity", area: "some area", likelihood: "some likelihood", estimated_cost: "120.5", timeframe: "some timeframe", notes: "some notes"}
  @update_attrs %{description: "some updated description", severity: "some updated severity", area: "some updated area", likelihood: "some updated likelihood", estimated_cost: "456.7", timeframe: "some updated timeframe", notes: "some updated notes"}
  @invalid_attrs %{description: nil, severity: nil, area: nil, likelihood: nil, estimated_cost: nil, timeframe: nil, notes: nil}

  defp create_impact(_) do
    impact = impact_fixture()
    %{impact: impact}
  end

  describe "Index" do
    setup [:create_impact]

    test "lists all impacts", %{conn: conn, impact: impact} do
      {:ok, _index_live, html} = live(conn, ~p"/impacts")

      assert html =~ "Listing Impacts"
      assert html =~ impact.description
    end

    test "saves new impact", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/impacts")

      assert index_live |> element("a", "New Impact") |> render_click() =~
               "New Impact"

      assert_patch(index_live, ~p"/impacts/new")

      assert index_live
             |> form("#impact-form", impact: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#impact-form", impact: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/impacts")

      html = render(index_live)
      assert html =~ "Impact created successfully"
      assert html =~ "some description"
    end

    test "updates impact in listing", %{conn: conn, impact: impact} do
      {:ok, index_live, _html} = live(conn, ~p"/impacts")

      assert index_live |> element("#impacts-#{impact.id} a", "Edit") |> render_click() =~
               "Edit Impact"

      assert_patch(index_live, ~p"/impacts/#{impact}/edit")

      assert index_live
             |> form("#impact-form", impact: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#impact-form", impact: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/impacts")

      html = render(index_live)
      assert html =~ "Impact updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes impact in listing", %{conn: conn, impact: impact} do
      {:ok, index_live, _html} = live(conn, ~p"/impacts")

      assert index_live |> element("#impacts-#{impact.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#impacts-#{impact.id}")
    end
  end

  describe "Show" do
    setup [:create_impact]

    test "displays impact", %{conn: conn, impact: impact} do
      {:ok, _show_live, html} = live(conn, ~p"/impacts/#{impact}")

      assert html =~ "Show Impact"
      assert html =~ impact.description
    end

    test "updates impact within modal", %{conn: conn, impact: impact} do
      {:ok, show_live, _html} = live(conn, ~p"/impacts/#{impact}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Impact"

      assert_patch(show_live, ~p"/impacts/#{impact}/show/edit")

      assert show_live
             |> form("#impact-form", impact: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#impact-form", impact: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/impacts/#{impact}")

      html = render(show_live)
      assert html =~ "Impact updated successfully"
      assert html =~ "some updated description"
    end
  end
end
