defmodule ResolvinatorWeb.MitigationLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.RisksFixtures

  @create_attrs %{status: "some status", description: "some description", strategy: "some strategy", effectiveness: "some effectiveness", cost: "120.5", start_date: "2024-10-29", target_date: "2024-10-29", completion_date: "2024-10-29", notes: "some notes"}
  @update_attrs %{status: "some updated status", description: "some updated description", strategy: "some updated strategy", effectiveness: "some updated effectiveness", cost: "456.7", start_date: "2024-10-30", target_date: "2024-10-30", completion_date: "2024-10-30", notes: "some updated notes"}
  @invalid_attrs %{status: nil, description: nil, strategy: nil, effectiveness: nil, cost: nil, start_date: nil, target_date: nil, completion_date: nil, notes: nil}

  defp create_mitigation(_) do
    mitigation = mitigation_fixture()
    %{mitigation: mitigation}
  end

  describe "Index" do
    setup [:create_mitigation]

    test "lists all mitigations", %{conn: conn, mitigation: mitigation} do
      {:ok, _index_live, html} = live(conn, ~p"/mitigations")

      assert html =~ "Listing Mitigations"
      assert html =~ mitigation.status
    end

    test "saves new mitigation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mitigations")

      assert index_live |> element("a", "New Mitigation") |> render_click() =~
               "New Mitigation"

      assert_patch(index_live, ~p"/mitigations/new")

      assert index_live
             |> form("#mitigation-form", mitigation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mitigation-form", mitigation: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mitigations")

      html = render(index_live)
      assert html =~ "Mitigation created successfully"
      assert html =~ "some status"
    end

    test "updates mitigation in listing", %{conn: conn, mitigation: mitigation} do
      {:ok, index_live, _html} = live(conn, ~p"/mitigations")

      assert index_live |> element("#mitigations-#{mitigation.id} a", "Edit") |> render_click() =~
               "Edit Mitigation"

      assert_patch(index_live, ~p"/mitigations/#{mitigation}/edit")

      assert index_live
             |> form("#mitigation-form", mitigation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mitigation-form", mitigation: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mitigations")

      html = render(index_live)
      assert html =~ "Mitigation updated successfully"
      assert html =~ "some updated status"
    end

    test "deletes mitigation in listing", %{conn: conn, mitigation: mitigation} do
      {:ok, index_live, _html} = live(conn, ~p"/mitigations")

      assert index_live |> element("#mitigations-#{mitigation.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mitigations-#{mitigation.id}")
    end
  end

  describe "Show" do
    setup [:create_mitigation]

    test "displays mitigation", %{conn: conn, mitigation: mitigation} do
      {:ok, _show_live, html} = live(conn, ~p"/mitigations/#{mitigation}")

      assert html =~ "Show Mitigation"
      assert html =~ mitigation.status
    end

    test "updates mitigation within modal", %{conn: conn, mitigation: mitigation} do
      {:ok, show_live, _html} = live(conn, ~p"/mitigations/#{mitigation}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Mitigation"

      assert_patch(show_live, ~p"/mitigations/#{mitigation}/show/edit")

      assert show_live
             |> form("#mitigation-form", mitigation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#mitigation-form", mitigation: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/mitigations/#{mitigation}")

      html = render(show_live)
      assert html =~ "Mitigation updated successfully"
      assert html =~ "some updated status"
    end
  end
end
