defmodule IKnoWeb.TopicLive.Topics do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts
  alias IKnoWeb.Components.SubjectTestingProgress

  def mount(%{"subject_id" => subject_id}, session, socket) do
    subject_id = String.to_integer(subject_id)
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

    subject = Knowledge.get_subject!(subject_id)
    learning_progress = Knowledge.get_learning_progress(subject_id, user_id)
    questions_available = Knowledge.get_unanswered_question(subject.id, user_id)

    socket =
      assign(socket,
        topics: topics,
        subject: subject,
        user_id: user_id,
        is_admin: is_admin,
        learning_progress: learning_progress,
        questions_available: questions_available,
        page_title: subject.name <> " Topics"
      )

    {:ok, socket}
  end

  def handle_event("review-topic", %{"topic-id" => topic_id}, socket) do
    topic_id = String.to_integer(topic_id)
    Knowledge.reset_learn_topic_progress(topic_id, socket.assigns.user_id)
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{topic_id}/learn")}
  end

  def handle_event("reset-subject", _, socket) do
    subject = socket.assigns.subject
    user_id = socket.assigns.user_id
    Knowledge.reset_learn_subject_progress(subject.id, user_id)
    Knowledge.delete_question_statuses(subject.id, user_id)

    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics")}
  end

  def handle_event("learn", _, socket) do
    if socket.assigns.learning_progress == 100 do
      Knowledge.reset_learn_subject_progress(socket.assigns.subject.id, socket.assigns.user_id)
    end

    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/learn")}
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
            class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-green-600 dark:text-gray-400 dark:hover:text-white"
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
            <a
              href={~p"/subjects/#{@subject.id}"}
              class="ml-1 text-sm font-medium text-gray-700 hover:text-green-600 md:ml-2 dark:text-gray-400 dark:hover:text-white"
            >
              <%= @subject.name %>
            </a>
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
      class="float-right p-2.5 ml-2 text-sm font-medium text-white bg-green-700 rounded-lg border border-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
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
          <li class="w-full px-4 py-2 border-b border-gray-200 rounded-t-lg dark:border-gray-600">
            <a
              href={~p"/subjects/#{topic.subject_id}/topics/#{topic.id}"}
              class={"font-medium #{if topic.known, do: 'text-lime-600', else: 'text-blue-600'} dark:text-blue-500 hover:underline"}
            >
              <%= topic.name %>
            </a>
            <a
              href={~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/test"}
              class={"float-right mx-2 font-medium #{if topic.known, do: 'text-lime-600', else: 'text-blue-600'} dark:text-blue-500 hover:underline"}
            >
              Test
            </a>
            <a
              :if={!Knowledge.is_known(topic.id, @user_id)}
              href={~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/learn"}
              class={"float-right font-medium #{if topic.known, do: 'text-lime-600', else: 'text-blue-600'} dark:text-blue-500 hover:underline"}
            >
              Learn
            </a>
            <a
              :if={Knowledge.is_known(topic.id, @user_id)}
              phx-click="review-topic"
              phx-value-topic-id={topic.id}
              href="#"
              class={"float-right font-medium #{if topic.known, do: 'text-lime-600', else: 'text-blue-600'} dark:text-blue-500 hover:underline"}
            >
              Review
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def render_buttons(assigns) do
    ~H"""
    <div class="mt-4">
      <button
        type="button"
        phx-click="learn"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <%= if @learning_progress < 100, do: "Learn", else: "Review" %>
      </button>
      <button
        :if={@is_admin}
        type="button"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href={~p"/subjects/#{@subject.id}/topics/new"}>New</a>
      </button>
      <button
        :if={@is_admin}
        phx-click="reset-subject"
        type="button"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        Reset Subject
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
    <.render_topics subject={@subject} topics={@topics} is_admin={@is_admin} user_id={@user_id}/>
    <div class="mt-2 w-full bg-gray-200 rounded-full h-1.5 mb-4 dark:bg-gray-700">
      <div class="bg-green-600 h-1.5 rounded-full dark:bg-green-500" style={"width: #{@learning_progress}%"}>
      </div>
    </div>
    <.render_buttons
      is_admin={@is_admin}
      subject={@subject}
      user_id={@user_id}
      learning_progress={@learning_progress}
    />
    <.live_component
      module={SubjectTestingProgress}
      id={:topics_progress}
      questions_available={@questions_available}
      is_admin={@is_admin}
      subject={@subject}
      user_id={@user_id}
    />
    """
  end
end
