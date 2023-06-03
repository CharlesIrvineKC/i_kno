defmodule IKnoWeb.TopicLive.Topics do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(%{"subject_id" => subject_id}, session, socket) do
    user_token = Map.get(session, "user_token")

    {user_id, is_admin, topics} =
      if user_token do
        user = Accounts.get_user_by_session_token(user_token)
        is_admin = Accounts.is_admin(subject_id, user.id)
        topics = Knowledge.list_subject_topics(subject_id, user.id)
        {user.id, is_admin, topics}
      else
        topics = Knowledge.list_subject_topics(subject_id, nil)
        {nil, false, topics}
      end

    subject_id = String.to_integer(subject_id)
    subject = Knowledge.get_subject!(subject_id)

    socket =
      assign(socket,
        topics: topics,
        subject: subject,
        user_id: user_id,
        is_admin: is_admin,
        page_title: subject.name <> " Topics"
      )

    {:ok, socket}
  end

  def handle_event("refresh-topic", %{"topic-id" => topic_id}, socket) do
    topic_id = String.to_integer(topic_id)
    Knowledge.reset_learn_topic_progress(topic_id, socket.assigns.user_id)
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{topic_id}/learn")}
  end

  def handle_event("reset-subject", _, socket) do
    Knowledge.reset_learn_subject_progress(socket.assigns.subject.id, socket.assigns.user_id)
    topics = Knowledge.list_subject_topics(socket.assigns.subject.id, socket.assigns.user_id)
    socket = assign(socket, topics: topics)
    {:noreply, socket}
  end

  def handle_event("delete", %{"topic-id" => topic_id}, socket) do
    topic = Knowledge.get_topic!(String.to_integer(topic_id))
    Knowledge.delete_topic(topic)
    subject_id = socket.assigns.subject.id
    user_id = socket.assigns.user_id
    topics = Knowledge.list_subject_topics(subject_id, user_id)
    socket = assign(socket, topics: topics)
    {:noreply, socket}
  end

  def handle_event("search", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/search")}
  end

  def render_breadcrumb(assigns) do
    ~H"""
    <nav class="pt-3 inline-block " aria-label="Breadcrumb">
      <ol class="inline-flex items-center space-x-1 md:space-x-3">
        <li class="inline-flex items-center">
          <a
            href={~p"/subjects"}
            class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white"
          >
            <svg
              aria-hidden="true"
              class="w-4 h-4 mr-2"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z">
              </path>
            </svg>
            Subjects
          </a>
        </li>
        <li>
          <div class="flex items-center">
            <svg
              aria-hidden="true"
              class="w-6 h-6 text-gray-400"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
            <span class="ml-1 text-sm font-medium text-gray-500 md:ml-2 dark:text-gray-400">
              <%= @subject.name %>
            </span>
          </div>
        </li>
      </ol>
    </nav>
    """
  end

  def render_searchbox(assigns) do
    ~H"""
    <button
      type="submit"
      phx-click="search"
      class="float-right p-2.5 ml-2 text-sm font-medium text-white bg-blue-700 rounded-lg border border-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      <svg
        class="w-5 h-5"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
        >
        </path>
      </svg>
      <span class="sr-only">Search</span>
    </button>
    """
  end

  def render_topics(assigns) do
    ~H"""
    <div>
      <h4 class="text-2xl font-bold dark:text-white">Topics</h4>
      <ul class="mt-1 text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white">
        <%= for topic <- @topics do %>
          <li
            class="w-full px-4 py-2 border-b border-gray-200 rounded-t-lg dark:border-gray-600"
          >
            <a
              href={~p"/subjects/#{topic.subject_id}/topics/#{topic.id}"}
              class={"font-medium #{if topic.known, do: 'text-lime-600', else: 'text-blue-600'} dark:text-blue-500 hover:underline"}
            >
              <%= topic.name %>
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def render_buttons(assigns) do
    ~H"""
    <div>
      <button
        :if={@is_admin}
        type="button"
        class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href={~p"/subjects/#{@subject.id}/topics/new"}>New</a>
      </button>
      <button
        :if={@user_id}
        type="button"
        data-popover-target="popover-learn"
        class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href={~p"/subjects/#{@subject.id}/learn"}>Learn</a>
      </button>
      <div
        data-popover
        id="popover-learn"
        role="tooltip"
        class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity transition-opacity duration-5000 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
      >
        <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
          <h3 class="font-semibold text-gray-900 dark:text-white">Learn Subject</h3>
        </div>
        <div class="px-3 py-2">
          <p>Let IKno present topics based on what you already know.</p>
        </div>
        <div data-popper-arrow></div>
      </div>
      <button
        :if={@user_id}
        type="button"
        phx-click="reset-subject"
        class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href="#">Reset Subject</a>
      </button>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="h-14">
      <.render_breadcrumb subject={@subject} />
      <.render_searchbox />
    </div>
    <.render_topics subject={@subject} topics={@topics} is_admin={@is_admin} />
    <.render_buttons is_admin={@is_admin} subject={@subject} user_id={@user_id} />
    """
  end
end
