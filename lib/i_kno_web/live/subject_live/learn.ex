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

    if topic != nil do
      socket = assign(socket, topic: topic)
      {:noreply, socket}
    else
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject_id}")}
    end
  end

  def handle_event("learn", _, socket) do
    Knowledge.set_learning(socket.assigns.topic.id, socket.assigns.user.id)
    socket = assign(socket, is_learning: true)
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
    <button
      phx-click="understood"
      class="mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      Understood
    </button>
    <button
      phx-click="learn"
      class="mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      Learn
    </button>
    """
  end
end
