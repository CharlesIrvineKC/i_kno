defmodule IKnoWeb.TopicLive.Topics do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    topics = Knowledge.list_subject_topics(subject_id, user.id)
    subject = Knowledge.get_subject!(subject_id)
    socket = assign(socket, topics: topics, subject: subject, user: user)
    {:ok, socket}
  end

  def handle_event("refresh", %{"topic-id" => topic_id}, socket) do
    topic_id = String.to_integer(topic_id)
    Knowledge.reset_learn_topic_progress(topic_id, socket.assigns.user.id)
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{topic_id}/learn")}
  end

  def handle_event("delete", %{"topic-id" => topic_id}, socket) do
    topic = Knowledge.get_topic!(String.to_integer(topic_id))
    Knowledge.delete_topic(topic)
    subject_id = socket.assigns.subject.id
    user_id = socket.assigns.user.id
    topics = Knowledge.list_subject_topics(subject_id, user_id)
    socket = assign(socket, topics: topics)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-4xl dark:text-white">
        <%= @subject.name %>
      </h1>
      <div class="relative overflow-x-auto sm:rounded-lg">
        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
          <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
              <th scope="col" class="px-6 py-3">
                Topic name
              </th>
              <th scope="col" class="px-6 py-3">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              :for={topic <- @topics}
              class="border-b bg-white dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
            >
              <th scope="row" class="px-6 py-1 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                <%= topic["name"] %>
              </th>
              <td class="px-6 py-1">
                <a
                  href={~p"/subjects/#{topic["subject_id"]}/topics/#{topic["id"]}"}
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  View
                </a>
                <a
                  :if={!topic["known"]}
                  href={~p"/subjects/#{topic["subject_id"]}/topics/#{topic["id"]}/learn"}
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Learn
                </a>
                <a
                  :if={topic["known"]}
                  phx-click="refresh"
                  phx-value-topic-id={topic["id"]}
                  href="#"
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Refresh
                </a>
                <a
                  href={~p"/subjects/#{topic["subject_id"]}/topics/#{topic["id"]}/edit"}
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Edit
                </a>
                <a
                  href="#"
                  phx-click="delete"
                  phx-value-topic-id={topic["id"]}
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Delete
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <button
      type="button"
      class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/#{@subject.id}/topics/new"}>New</a>
    </button>
    <button
      type="button"
      class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/#{@subject.id}/topics/learn"}>Learn</a>
    </button>
    """
  end
end
