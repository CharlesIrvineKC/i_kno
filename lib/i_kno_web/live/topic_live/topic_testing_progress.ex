defmodule IKnoWeb.TopicLive.TopicTestingProgress do
  use IKnoWeb, :live_component

  alias IKno.Knowledge

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    test_progress = Knowledge.get_topic_test_progress(socket.assigns.topic.id, socket.assigns.user_id)
    {total, num_answered, num_correct} = get_test_summary(test_progress)

    socket =
      assign(socket,
        test_progress: test_progress,
        total: total,
        num_answered: num_answered,
        num_correct: num_correct
      )

    {:ok, socket}
  end

  # returns {total, num_answered, num_correct}
  def get_test_summary([]), do: {0, 0, 0}

  def get_test_summary([[_question_id, status, _] | rest]) do
    answered = if status != nil, do: 1, else: 0
    correct = if status == "passed", do: 1, else: 0
    {t, a, c} = get_test_summary(rest)
    {t + 1, a + answered, c + correct}
  end

  def percent_tested(total, num_correct) do
    round(num_correct / total * 100)
  end

  def handle_event("retest-all", _, socket) do
    test_progress = socket.assigns.test_progress
    topic = socket.assigns.topic

    answered_questions =
      Enum.filter(test_progress, fn [_id, status, _status_id] -> status != nil end)

    question_ids = Enum.map(answered_questions, fn q -> Enum.at(q, 2) end)

    Knowledge.delete_question_statuses(question_ids)

    {:noreply, redirect(socket, to: ~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/test")}
  end

  def handle_event("retest-incorrect", _, socket) do
    test_progress = socket.assigns.test_progress
    topic = socket.assigns.topic

    incorrect_questions =
      Enum.filter(test_progress, fn [_id, status, _status_id] -> status == "failed" end)

    question_ids = Enum.map(incorrect_questions, fn q -> Enum.at(q, 2) end)

    Knowledge.delete_question_statuses(question_ids)

    {:noreply, redirect(socket, to: ~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/test")}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@user_id && @total > 0}>
        <h4 class="text-2xl  mt-10 mb-1 font-bold dark:text-white">Testing Progress</h4>
        <div class="border rounded border-grey-900 p-3">
          <ul class="max-w space-y-1 text-gray-800 list-disc list-inside dark:text-gray-400">
            <li>
              <%= "Questions Answered: #{@num_answered} of #{@total}" %>
            </li>
            <li>
              <%= "Questions Answered Correctly: #{@num_correct} of #{@num_answered}" %>
            </li>
            <li :if={!@questions_available && (@num_answered != @total)}>
              No questions currently available. You need to learn more topics.
            </li>
          </ul>
        </div>
        <div class="mt-16 w-full bg-gray-200 rounded-full h-1.5 mb-4 mt-4 dark:bg-gray-700">
          <div
            class="bg-green-600 h-1.5 rounded-full dark:bg-green-500"
            style={"width: #{percent_tested(@total, @num_correct)}%"}
          >
          </div>
        </div>
        <.render_progress_buttons
          is_admin={@is_admin}
          topic={@topic}
          user_id={@user_id}
          myself={@myself}
          total={@total}
          num_answered={@num_answered}
          questions_available={@questions_available}
          num_correct={@num_correct}
        />
      </div>
    </div>
    """
  end

  def render_progress_buttons(assigns) do
    ~H"""
    <div class="mt-4">
      <button
        :if={@num_answered < @total && @questions_available}
        type="button"
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        <a href={~p"/subjects/#{@topic.subject_id}/topics/#{@topic.id}/test"}>Test</a>
      </button>
      <button
        :if={@num_correct < @num_answered}
        type="button"
        phx-click="retest-incorrect"
        phx-target={@myself}
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        Retest Incorrect
      </button>
      <button
        :if={@num_answered > 0}
        type="button"
        phx-click="retest-all"
        phx-target={@myself}
        class="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        Retest All
      </button>
    </div>
    """
  end
end
