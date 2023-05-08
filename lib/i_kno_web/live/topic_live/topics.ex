defmodule IKnoWeb.TopicLive.Topics do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    topics = Knowledge.list_subject_topics(subject_id, user.id)
    subject = Knowledge.get_subject!(subject_id)
    socket = assign(socket, topics: topics, subject: subject, user: user, tasks_only: true)
    {:ok, socket}
  end

  def handle_event("refresh-topic", %{"topic-id" => topic_id}, socket) do
    topic_id = String.to_integer(topic_id)
    Knowledge.reset_learn_topic_progress(topic_id, socket.assigns.user.id)
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{topic_id}/learn")}
  end

  def handle_event("tasks-only", params, socket) do
    case params do
      %{"value" => "checked"} ->
        topics = Knowledge.list_subject_topics(socket.assigns.subject.id, socket.assigns.user.id)
        {:noreply, assign(socket, tasks_only: true, topics: topics)}

      _else ->
        topics = Knowledge.list_subject_topics(socket.assigns.subject.id, socket.assigns.user.id)
        {:noreply, assign(socket, tasks_only: false, topics: topics)}
    end
  end

  def handle_event("reset-subject", _, socket) do
    Knowledge.reset_learn_subject_progress(socket.assigns.subject.id, socket.assigns.user.id)
    topics = Knowledge.list_subject_topics(socket.assigns.subject.id, socket.assigns.user.id)
    socket = assign(socket, topics: topics)
    {:noreply, socket}
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
            <%= for topic <- @topics do %>
              <tr
                :if={!@tasks_only || topic.is_task}
                class="border-b bg-white dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
              >
                <th scope="row" class="px-6 py-1 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                  <%= topic.name %>
                </th>
                <td class="px-6 py-1">
                  <a
                    href={~p"/subjects/#{topic.subject_id}/topics/#{topic.id}"}
                    class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                  >
                    View
                  </a>
                  <a
                    :if={!topic.known}
                    href={~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/learn"}
                    class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                  >
                    Learn
                  </a>
                  <a
                    :if={topic.known}
                    phx-click="refresh-topic"
                    phx-value-topic-id={topic.id}
                    href="#"
                    class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                  >
                    Reset
                  </a>
                  <a
                    href={~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/edit"}
                    class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                  >
                    Edit
                  </a>
                  <a
                    href="#"
                    phx-click="delete"
                    phx-value-topic-id={topic.id}
                    class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                  >
                    Delete
                  </a>
                </td>
              </tr>
            <% end %>
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
    <button
      type="button"
      phx-click="reset-subject"
      class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href="#">Reset Subject</a>
    </button>
    <%= if @tasks_only do %>
      <input
        checked
        id="tasks-only"
        name="tasks-only"
        phx-click="tasks-only"
        type="checkbox"
        value="checked"
        class="ml-6 w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
      />
    <% else %>
      <input
        checked
        id="tasks-only"
        name="tasks-only"
        phx-click="tasks-only"
        type="checkbox"
        value="checked"
        class="ml-6 w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
      />
    <% end %>
    <label for="tasks-only" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
      Tasks Only
    </label>
    <input
      id="default-checkbox"
      type="checkbox"
      value=""
      class="ml-2 w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
    />
    <label for="default-checkbox" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
      Unknown Only
    </label>
    """
  end
end
