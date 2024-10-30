defmodule ResolvinatorWeb.RiskLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.RisksFixtures

  @create_attrs %{name: "some name", priority: "some priority", status: "some status", description: "some description", probability: "some probability", impact: "some impact", mitigation_status: "some mitigation_status", detection_date: "2024-10-29", review_date: "2024-10-29"}
  @update_attrs %{name: "some updated name", priority: "some updated priority", status: "some updated status", description: "some updated description", probability: "some updated probability", impact: "some updated impact", mitigation_status: "some updated mitigation_status", detection_date: "2024-10-30", review_date: "2024-10-30"}
  @invalid_attrs %{name: nil, priority: nil, status: nil, description: nil, probability: nil, impact: nil, mitigation_status: nil, detection_date: nil, review_date: nil}

  defp create_risk(_) do
    risk = risk_fixture()
    %{risk: risk}
  end

  describe "Index" do
    setup [:create_risk]

    test "lists all risks", %{conn: conn, risk: risk} do
      {:ok, _index_live, html} = live(conn, ~p"/risks")

      assert html =~ "Listing Risks"
      assert html =~ risk.name
    end

    test "saves new risk", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/risks")

      assert index_live |> element("a", "New Risk") |> render_click() =~
               "New Risk"

      assert_patch(index_live, ~p"/risks/new")

      assert index_live
             |> form("#risk-form", risk: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#risk-form", risk: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/risks")

      html = render(index_live)
      assert html =~ "Risk created successfully"
      assert html =~ "some name"
    end

    test "updates risk in listing", %{conn: conn, risk: risk} do
      {:ok, index_live, _html} = live(conn, ~p"/risks")

      assert index_live |> element("#risks-#{risk.id} a", "Edit") |> render_click() =~
               "Edit Risk"

      assert_patch(index_live, ~p"/risks/#{risk}/edit")

      assert index_live
             |> form("#risk-form", risk: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#risk-form", risk: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/risks")

      html = render(index_live)
      assert html =~ "Risk updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes risk in listing", %{conn: conn, risk: risk} do
      {:ok, index_live, _html} = live(conn, ~p"/risks")

      assert index_live |> element("#risks-#{risk.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#risks-#{risk.id}")
    end
  end

  describe "Show" do
    setup [:create_risk]

    test "displays risk", %{conn: conn, risk: risk} do
      {:ok, _show_live, html} = live(conn, ~p"/risks/#{risk}")

      assert html =~ "Show Risk"
      assert html =~ risk.name
    end

    test "updates risk within modal", %{conn: conn, risk: risk} do
      {:ok, show_live, _html} = live(conn, ~p"/risks/#{risk}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Risk"

      assert_patch(show_live, ~p"/risks/#{risk}/show/edit")

      assert show_live
             |> form("#risk-form", risk: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#risk-form", risk: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/risks/#{risk}")

      html = render(show_live)
      assert html =~ "Risk updated successfully"
      assert html =~ "some updated name"
    end
  end
end
