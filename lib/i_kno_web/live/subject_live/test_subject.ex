defmodule IKnoWeb.SubjectLive.TestSubject do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts
  alias IKnoWeb.Highlighter

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    question = Knowledge.get_unanswered_question(subject_id, user.id)

    answers =
      if question.type == "multiple_choice" do
        Knowledge.list_answers(question.id)
      else
        nil
      end

    socket = assign(socket, question: question, answers: answers)
    {:ok, socket}
  end

  def handle_event("correct-answer", _, socket) do
    {:noreply, socket}
  end

  def handle_event("not-correct-answer", _, socket) do
    {:noreply, socket}
  end

  def render_topic_question(assigns) do
    ~H"""
    <div>
      <div class="border rounded border-grey-900 p-5">
        <section class="markdown mb-5" id="topic-discription" phx-hook="Mount">
          <%= Highlighter.highlight(Earmark.as_html!(@question.question)) |> Phoenix.HTML.raw() %>
        </section>
        <form :if={@question.type == "true_false"}>
          <div class="flex items-center mb-4">
            <input
              id="default-radio-1"
              type="radio"
              value=""
              name="default-radio"
              class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
            />
            <label for="default-radio-1" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
              True
            </label>
          </div>
          <div class="flex items-center">
            <input
              id="default-radio-2"
              type="radio"
              value=""
              name="default-radio"
              class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
            />
            <label for="default-radio-2" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
              False
            </label>
          </div>
        </form>
        <form :if={@question.type == "multiple_choice"}>
          <div :for={answer <- @answers} class="flex items-center mb-2">
            <input
              id={"default-checkbox-#{answer.id}"}
              type="checkbox"
              value=""
              class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
            />
            <label
              for="default-checkbox"
              class="markdown ml-2 text-sm font-medium text-center text-gray-900 dark:text-gray-300"
              id={"answer-#{answer.id}"}
              phx-hook="Mount"
            >
                <%= Highlighter.highlight(Earmark.as_html!(answer.answer)) |> Phoenix.HTML.raw() %>
            </label>
          </div>
        </form>
      </div>
      <button
        type="submit"
        class="mt-3 px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Submit
      </button>
      <button
        type="submit"
        class="mt-3 px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Stop Testing
      </button>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <.render_topic_question question={@question} answers={@answers} />
    """
  end
end
