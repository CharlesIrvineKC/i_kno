defmodule IKnoWeb.SubjectLive.Learn do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    topic = Knowledge.get_unknown_topic(subject_id, user.id)
    socket = assign(socket, topic: topic, user: user, subject_id: subject_id)
    {:ok, socket}
  end

  def handle_event("understood", _, socket) do
    Knowledge.set_known(socket.assigns.topic.id, socket.assigns.user.id)
    topic = Knowledge.get_unknown_topic(socket.assigns.subject_id, socket.assigns.user.id)

    socket = assign(socket, topic: topic)
    {:noreply, socket}
  end

  def handle_event("learn", _, socket) do
    Knowledge.set_learning(socket.assigns.topic.id, socket.assigns.user.id)
    socket = assign(socket, is_learning: true)
    {:noreply, socket}
  end

  def handle_event("review", _, socket) do
    Knowledge.reset_subject_progress(socket.assigns.subject_id, socket.assigns.user.id)
    topic = Knowledge.get_unknown_topic(socket.assigns.subject_id, socket.assigns.user.id)
    socket = assign(socket, topic: topic)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <%= if @topic == nil do %>
      <h1 class="mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
       Congradulations!
      </h1>
      <p class="mb-6 text-lg font-normal text-gray-500 lg:text-xl sm:px-16 xl:px-48 dark:text-gray-400">
        You have completed your review of this subject. Click the button below if you would like to review the subject again.
      </p>
      <a
        phx-click="review"
        href="#"
        class="inline-flex items-center justify-center px-5 py-3 text-base font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-900"
      >
        Review
      </a>
    <% else %>
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
