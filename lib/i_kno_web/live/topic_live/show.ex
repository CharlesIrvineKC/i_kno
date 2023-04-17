defmodule IKnoWeb.TopicLive.Show do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(%{"topic_id" => topic_id}, %{"user_token" => user_token}, socket) do
    topic_id = String.to_integer(topic_id)
    user = Accounts.get_user_by_session_token(user_token)
    topic = Knowledge.get_topic!(topic_id)
    is_known = Knowledge.get_known(topic_id, user.id)
    socket = assign(socket, topic: topic, is_known: is_known, user: user)
    {:ok, socket}
  end

  def handle_event("understood", _, socket) do
    Knowledge.set_known(socket.assigns.topic.id, socket.assigns.user.id)
    socket = assign(socket, is_known: true)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-4xl dark:text-white">
      <%= @topic.name %>
    </h1>
    <p class="text-black dark:text-gray-400">
      <section class="markdown">
        <%= Earmark.as_html!(@topic.description,
          escape: false,
          inner_html: true,
          compact_output: true
        )
        |> Phoenix.HTML.raw() %>
      </section>
    </p>
    <%= if @is_known do %>
    <% else %>
      <button
        phx-click="understood"
        class="mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Understood
      </button>
    <% end %>
    """
  end
end
