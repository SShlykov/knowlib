defmodule KnowlibWeb.PageLiveTest do
  use KnowlibWeb.ConnCase

  import Phoenix.LiveViewTest
  import Knowlib.KnowledgeFixtures

  @create_attrs %{title: "some title", text: "some text", order: 42}
  @update_attrs %{title: "some updated title", text: "some updated text", order: 43}
  @invalid_attrs %{title: nil, text: nil, order: nil}

  defp create_page(_) do
    page = page_fixture()
    %{page: page}
  end

  describe "Index" do
    setup [:create_page]

    test "lists all pages", %{conn: conn, page: page} do
      {:ok, _index_live, html} = live(conn, ~p"/pages")

      assert html =~ "Listing Pages"
      assert html =~ page.title
    end

    test "saves new page", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/pages")

      assert index_live |> element("a", "New Page") |> render_click() =~
               "New Page"

      assert_patch(index_live, ~p"/pages/new")

      assert index_live
             |> form("#page-form", page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#page-form", page: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/pages")

      html = render(index_live)
      assert html =~ "Page created successfully"
      assert html =~ "some title"
    end

    test "updates page in listing", %{conn: conn, page: page} do
      {:ok, index_live, _html} = live(conn, ~p"/pages")

      assert index_live |> element("#pages-#{page.id} a", "Edit") |> render_click() =~
               "Edit Page"

      assert_patch(index_live, ~p"/pages/#{page}/edit")

      assert index_live
             |> form("#page-form", page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#page-form", page: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/pages")

      html = render(index_live)
      assert html =~ "Page updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes page in listing", %{conn: conn, page: page} do
      {:ok, index_live, _html} = live(conn, ~p"/pages")

      assert index_live |> element("#pages-#{page.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#pages-#{page.id}")
    end
  end

  describe "Show" do
    setup [:create_page]

    test "displays page", %{conn: conn, page: page} do
      {:ok, _show_live, html} = live(conn, ~p"/pages/#{page}")

      assert html =~ "Show Page"
      assert html =~ page.title
    end

    test "updates page within modal", %{conn: conn, page: page} do
      {:ok, show_live, _html} = live(conn, ~p"/pages/#{page}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Page"

      assert_patch(show_live, ~p"/pages/#{page}/show/edit")

      assert show_live
             |> form("#page-form", page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#page-form", page: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/pages/#{page}")

      html = render(show_live)
      assert html =~ "Page updated successfully"
      assert html =~ "some updated title"
    end
  end
end
