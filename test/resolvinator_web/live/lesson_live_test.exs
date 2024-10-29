defmodule ResolvinatorWeb.LessonLiveTest do
  use ResolvinatorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvinator.ContentFixtures

  @create_attrs %{name: "some name", desc: "some desc", upvotes: 42, downvotes: 42}
  @update_attrs %{name: "some updated name", desc: "some updated desc", upvotes: 43, downvotes: 43}
  @invalid_attrs %{name: nil, desc: nil, upvotes: nil, downvotes: nil}

  defp create_lesson(_) do
    lesson = lesson_fixture()
    %{lesson: lesson}
  end

  describe "Index" do
    setup [:create_lesson]

    test "lists all lessons", %{conn: conn, lesson: lesson} do
      {:ok, _index_live, html} = live(conn, ~p"/lessons")

      assert html =~ "Listing Lessons"
      assert html =~ lesson.name
    end

    test "saves new lesson", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert index_live |> element("a", "New Lesson") |> render_click() =~
               "New Lesson"

      assert_patch(index_live, ~p"/lessons/new")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#lesson-form", lesson: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/lessons")

      html = render(index_live)
      assert html =~ "Lesson created successfully"
      assert html =~ "some name"
    end

    test "updates lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert index_live |> element("#lessons-#{lesson.id} a", "Edit") |> render_click() =~
               "Edit Lesson"

      assert_patch(index_live, ~p"/lessons/#{lesson}/edit")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#lesson-form", lesson: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/lessons")

      html = render(index_live)
      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert index_live |> element("#lessons-#{lesson.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lessons-#{lesson.id}")
    end
  end

  describe "Show" do
    setup [:create_lesson]

    test "displays lesson", %{conn: conn, lesson: lesson} do
      {:ok, _show_live, html} = live(conn, ~p"/lessons/#{lesson}")

      assert html =~ "Show Lesson"
      assert html =~ lesson.name
    end

    test "updates lesson within modal", %{conn: conn, lesson: lesson} do
      {:ok, show_live, _html} = live(conn, ~p"/lessons/#{lesson}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Lesson"

      assert_patch(show_live, ~p"/lessons/#{lesson}/show/edit")

      assert show_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#lesson-form", lesson: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/lessons/#{lesson}")

      html = render(show_live)
      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated name"
    end
  end
end
