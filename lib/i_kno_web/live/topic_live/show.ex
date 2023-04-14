defmodule IKnoWeb.TopicLive.Show do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  def mount(%{"topic_id" => topic_id}, _session, socket) do
    topic = Knowledge.get_topic!(topic_id)
    socket = assign(socket, topic: topic)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-4xl dark:text-white">
      <%= @topic.name %>
    </h1>
    <p class="text-black dark:text-gray-400">
    <%= Earmark.as_html!(@topic.description, escape: false, inner_html: true, compact_output: true)
    |> Phoenix.HTML.raw() %>
    </p>
    """
  end
end
