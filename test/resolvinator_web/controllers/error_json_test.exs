defmodule ResolvinatorWeb.ErrorJSONTest do
  use ResolvinatorWeb.ConnCase, async: true

  test "renders 404" do
    assert ResolvinatorWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ResolvinatorWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
