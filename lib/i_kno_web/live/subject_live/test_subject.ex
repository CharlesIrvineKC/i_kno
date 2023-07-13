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
      if question && question.type == "multiple_choice" do
        Knowledge.list_answers(question.id)
      else
        nil
      end

    socket = assign(socket, question: question, answers: answers, subject_id: subject_id, user: user)
    {:ok, socket}
  end

  def is_correct(answer, params) do
    true_ids = Enum.map(Map.keys(params), fn key -> String.to_integer(key) end)

    if answer.is_correct do
      Enum.member?(true_ids, answer.id)
    else
      !Enum.member?(true_ids, answer.id)
    end
  end

  def handle_event("submit-mc-answers", params, socket) do
    %{answers: answers, question: question, user: user, subject_id: subject_id} = socket.assigns

    passed? =
      answers
      |> Enum.map(fn answer -> is_correct(answer, params) end)
      |> Enum.reduce(fn bool, acc -> bool && acc end)

    status = if passed?, do: :passed, else: :failed

    Knowledge.create_user_question_status(%{
      status: status,
      question_id: question.id,
      user_id: user.id,
      topic_id: question.topic_id,
      subject_id: subject_id
    })

    question = Knowledge.get_unanswered_question(subject_id, user.id)

    socket = assign(socket, question: question)
    {:noreply, socket}
  end

  def handle_event("submit-tf-answer", %{"true?" => true?}, socket) do
    %{question: question, user: user, subject_id: subject_id} = socket.assigns
    true? = String.to_atom(true?)
    status = if true? == question.is_correct, do: :passed, else: :failed

    Knowledge.create_user_question_status(%{
      status: status,
      question_id: question.id,
      user_id: user.id,
      topic_id: question.topic_id,
      subject_id: subject_id
    })

    question = Knowledge.get_unanswered_question(subject_id, user.id)
    socket = assign(socket, question: question)

    {:noreply, socket}
  end

  def render_topic_question(assigns) do
    ~H"""
    <div>
      <div>
        <.render_multiple_choice
          :if={@question.type == "multiple_choice"}
          question={@question}
          answers={@answers}
        />
        <.render_true_false :if={@question.type == "true_false"} question={@question} answers={@answers} />
      </div>
    </div>
    """
  end

  def render_multiple_choice(assigns) do
    ~H"""
    <form phx-submit="submit-mc-answers">
      <div class="border rounded border-grey-900 p-5">
        <section class="markdown mb-5" id="topic-discription" phx-hook="Mount">
          <%= Highlighter.highlight(Earmark.as_html!(@question.question)) |> Phoenix.HTML.raw() %>
        </section>
        <div>
          <div :for={answer <- @answers} class="flex items-center mb-2 ">
            <input
              id={"#{answer.id}"}
              name={"#{answer.id}"}
              type="checkbox"
              value="true"
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
        </div>
      </div>
      <button
        type="submit"
        class="mt-3 px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Submit
      </button>
      <button
        type="button"
        class="mt-3 px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Stop Testing
      </button>
    </form>
    """
  end

  def render_true_false(assigns) do
    ~H"""
    <form phx-submit="submit-tf-answer">
      <div class="border rounded border-grey-900 p-5">
        <section class="markdown mb-5" id="topic-discription" phx-hook="Mount">
          <%= Highlighter.highlight(Earmark.as_html!(@question.question)) |> Phoenix.HTML.raw() %>
        </section>
        <div class="flex items-center mb-4">
          <input
            id="true-button"
            name="true?"
            type="radio"
            value="true"
            name="default-radio"
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
          />
          <label for="default-radio-1" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
            True
          </label>
        </div>
        <div class="flex items-center">
          <input
            id="false-button"
            name="true?"
            type="radio"
            value="false"
            name="default-radio"
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
          />
          <label for="default-radio-2" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
            False
          </label>
        </div>
      </div>
      <button
        type="submit"
        class="mt-3 px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Submit
      </button>
      <button
        type="button"
        class="mt-3 px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Stop Testing
      </button>
    </form>
    """
  end

  def render_subject_test_complete(assigns) do
    ~H"""
    <h1>Subject Test Complete</h1>
    """
  end

  def render(assigns) do
    ~H"""
    <%= if @question do %>
      <.render_topic_question question={@question} answers={@answers} />
    <% else %>
      <.render_subject_test_complete />
    <% end %>
    """
  end
end
