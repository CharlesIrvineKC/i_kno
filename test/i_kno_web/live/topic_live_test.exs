defmodule IKnoWeb.TopicLiveTest do
  use IKnoWeb.ConnCase

  import Phoenix.LiveViewTest
  import IKno.KnowledgeFixtures

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  defp create_topic(_) do
    topic = topic_fixture()
    %{topic: topic}
  end

  describe "Index" do
    setup [:create_topic]

    test "lists all topics", %{conn: conn, topic: topic} do
      {:ok, _index_live, html} = live(conn, ~p"/topics")

      assert html =~ "Listing Topics"
      assert html =~ topic.description
    end

    test "saves new topic", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/topics")

      assert index_live |> element("a", "New Topic") |> render_click() =~
               "New Topic"

      assert_patch(index_live, ~p"/topics/new")

      assert index_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#topic-form", topic: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/topics")

      html = render(index_live)
      assert html =~ "Topic created successfully"
      assert html =~ "some description"
    end

    test "updates topic in listing", %{conn: conn, topic: topic} do
      {:ok, index_live, _html} = live(conn, ~p"/topics")

      assert index_live |> element("#topics-#{topic.id} a", "Edit") |> render_click() =~
               "Edit Topic"

      assert_patch(index_live, ~p"/topics/#{topic}/edit")

      assert index_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#topic-form", topic: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/topics")

      html = render(index_live)
      assert html =~ "Topic updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes topic in listing", %{conn: conn, topic: topic} do
      {:ok, index_live, _html} = live(conn, ~p"/topics")

      assert index_live |> element("#topics-#{topic.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#topics-#{topic.id}")
    end
  end

  describe "Show" do
    setup [:create_topic]

    test "displays topic", %{conn: conn, topic: topic} do
      {:ok, _show_live, html} = live(conn, ~p"/topics/#{topic}")

      assert html =~ "Show Topic"
      assert html =~ topic.description
    end

    test "updates topic within modal", %{conn: conn, topic: topic} do
      {:ok, show_live, _html} = live(conn, ~p"/topics/#{topic}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Topic"

      assert_patch(show_live, ~p"/topics/#{topic}/show/edit")

      assert show_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#topic-form", topic: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/topics/#{topic}")

      html = render(show_live)
      assert html =~ "Topic updated successfully"
      assert html =~ "some updated description"
    end
  end
end
