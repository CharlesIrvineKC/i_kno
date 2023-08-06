defmodule IKnoWeb.Components.TestingProgress do
  use IKnoWeb, :live_component

  alias IKno.Knowledge

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    test_progress = Knowledge.get_test_progress(socket.assigns.subject.id, socket.assigns.user_id)
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

  def get_test_summary([[_question_id, _topic_id, status, _] | rest]) do
    answered = if status != nil, do: 1, else: 0
    correct = if status == "passed", do: 1, else: 0
    {t, a, c} = get_test_summary(rest)
    {t + 1, a + answered, c + correct}
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

  def percent_tested(total, num_correct) do
    round((num_correct / total) * 100)
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@user_id && @total > 0}>
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
        <div :if={@total > 0} class="w-full bg-gray-200 rounded-full h-1.5 mb-4 mt-4 dark:bg-gray-700">
          <div class="bg-green-600 h-1.5 rounded-full dark:bg-green-500"
               style={"width: #{percent_tested(@total, @num_correct)}%"}></div>
        </div>
        <.render_progress_buttons is_admin={@is_admin} subject={@subject} user_id={@user_id} myself={@myself} />
      </div>
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
        phx-target={@myself}
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
        phx-target={@myself}
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
end
