defmodule IKnoWeb.TopicLive.Topics do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

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

    test_progress = Knowledge.get_test_progress(subject_id, user_id)

    socket =
      assign(socket,
        topics: topics,
        subject: subject,
        user_id: user_id,
        is_admin: is_admin,
        page_title: subject.name <> " Topics",
        test_progress: test_progress
      )

    {:ok, socket}
  end

  # returns {total, num_answered, num_correct}
  def get_test_summary([]), do: {0, 0, 0}

  def get_test_summary([[_question_id, _topic_id, status, _] | rest]) do
    answered = if status != nil, do: 1, else: 0
    correct = if status == "passed", do: 1, else: 0
    {t, a, c} = get_test_summary(rest)
    {t + 1, a + answered, c + correct}
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

  def handle_event("retest-all", _, socket) do
    test_progress = socket.assigns.test_progress

    answered_questions =
      Enum.filter(test_progress, fn [_id, _topic_id, status, _status_id] -> status != nil end)
    question_ids = Enum.map(answered_questions, fn q -> Enum.at(q, 3) end)

    Knowledge.delete_question_statuses(question_ids)

    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/test")}
  end

  def handle_event("retest-incorrect", _, socket) do
    test_progress = socket.assigns.test_progress

    incorrect_questions =
      Enum.filter(test_progress, fn [_id, _topic_id, status, _status_id] -> status == "failed" end)
    question_ids = Enum.map(incorrect_questions, fn q -> Enum.at(q, 3) end)

    Knowledge.delete_question_statuses(question_ids)

    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/test")}
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
            <a
              href={~p"/subjects/#{@subject.id}"}
              class="ml-1 text-sm font-medium text-gray-700 hover:text-blue-600 md:ml-2 dark:text-gray-400 dark:hover:text-white"
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
          <li class="w-full px-4 py-2 border-b border-gray-200 rounded-t-lg dark:border-gray-600">
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
    <div class="mt-4">
      <button
        :if={@is_admin}
        type="button"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href={~p"/subjects/#{@subject.id}/topics/new"}>New</a>
      </button>
      <button
        type="button"
        data-popover-target="popover-learn"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href={~p"/subjects/#{@subject.id}/learn"}>Learn</a>
      </button>
      <button
        :if={@user_id}
        type="button"
        phx-click="reset-subject"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href="#">Reset Subject</a>
      </button>
    </div>
    """
  end

  def render_progress_buttons(assigns) do
    ~H"""
    <div class="mt-4">
      <button
        type="button"
        data-popover-target="popover-learn"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href={~p"/subjects/#{@subject.id}/test"}>Test</a>
      </button>
      <div
        data-popover
        id="popover-learn"
        role="tooltip"
        class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity transition-opacity duration-5000 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
      >
        <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
          <h3 class="font-semibold text-gray-900 dark:text-white">Test Subject</h3>
        </div>
        <div class="px-3 py-2">
          <p>Let IKno test you on your knowledge of this subject. <strong>Requires login.</strong></p>
        </div>
        <div data-popper-arrow></div>
      </div>
      <button
        type="button"
        phx-click="retest-incorrect"
        data-popover-target="popover-learn"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        Re-test Incorrect
      </button>
      <div
        data-popover
        id="popover-learn"
        role="tooltip"
        class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity transition-opacity duration-5000 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
      >
        <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
          <h3 class="font-semibold text-gray-900 dark:text-white">Test Subject</h3>
        </div>
        <div class="px-3 py-2">
          <p>Let IKno test you on your knowledge of this subject. <strong>Requires login.</strong></p>
        </div>
        <div data-popper-arrow></div>
      </div>
      <button
        type="button"
        phx-click="retest-all"
        data-popover-target="popover-learn"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        Re-test All
      </button>
      <div
        data-popover
        id="popover-learn"
        role="tooltip"
        class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity transition-opacity duration-5000 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
      >
        <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
          <h3 class="font-semibold text-gray-900 dark:text-white">Test Subject</h3>
        </div>
        <div class="px-3 py-2">
          <p>Let IKno test you on your knowledge of this subject. <strong>Requires login.</strong></p>
        </div>
        <div data-popper-arrow></div>
      </div>
    </div>
    """
  end

  def render_progress(assigns) do
    {total, num_answered, num_correct} = get_test_summary(assigns.test_progress)

    assigns =
      assigns
      |> Map.put(:total, total)
      |> Map.put(:num_answered, num_answered)
      |> Map.put(:num_correct, num_correct)

    ~H"""
    <div :if={@user_id}>
      <h4 class="text-2xl  mt-10 mb-1 font-bold dark:text-white">Testing Progress</h4>
      <div class="border rounded border-grey-900 p-3">
        <ul class="max-w-md space-y-1 text-gray-800 list-disc list-inside dark:text-gray-400">
          <li>
            <%= "Questions Answered: #{@num_answered} of #{@total}" %>
          </li>
          <li>
            <%= "Questions Answered Correctly: #{@num_correct} of #{@num_answered}" %>
          </li>
        </ul>
      </div>
      <.render_progress_buttons is_admin={@is_admin} subject={@subject} user_id={@user_id} />
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
    <.render_progress is_admin={@is_admin} subject={@subject} user_id={@user_id} test_progress={@test_progress} />
    """
  end
end
