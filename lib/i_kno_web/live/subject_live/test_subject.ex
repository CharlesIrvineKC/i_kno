defmodule IKnoWeb.SubjectLive.TestSubject do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts
  alias IKnoWeb.AnswerQuestion

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    subject = Knowledge.get_subject!(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    question = Knowledge.get_unanswered_question(subject.id, user.id)

    if question do
      answers = get_answers(question)

      socket = assign(socket, question: question, answers: answers, subject: subject, user: user)
      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/subjects/#{subject.id}/topics")}
    end
  end

  defp get_answers(question) do
    if question && question.type == "multiple_choice" do
      Knowledge.list_answers(question.id)
    else
      []
    end
  end

  def is_correct(answer, params) do
    true_ids = Enum.map(Map.keys(params), fn key -> String.to_integer(key) end)

    if answer.is_correct do
      Enum.member?(true_ids, answer.id)
    else
      !Enum.member?(true_ids, answer.id)
    end
  end

  def handle_event("stop-testing", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics")}
  end

  def handle_event("submit-mc-answers", params, socket) do
    %{answers: answers, question: question, user: user, subject: subject} = socket.assigns

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
      subject_id: subject.id
    })

    question = Knowledge.get_unanswered_question(subject.id, user.id)

    if question do
      answers = get_answers(question)

      socket = assign(socket, question: question, answers: answers)
      {:noreply, socket}
    else
      {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics")}
    end
  end

  def handle_event("submit-tf-answer", %{"true?" => true?}, socket) do
    %{question: question, user: user, subject: subject} = socket.assigns
    true? = String.to_atom(true?)
    status = if true? == question.is_correct, do: :passed, else: :failed

    Knowledge.create_user_question_status(%{
      status: status,
      question_id: question.id,
      user_id: user.id,
      topic_id: question.topic_id,
      subject_id: subject.id
    })

    question = Knowledge.get_unanswered_question(subject.id, user.id)

    if question do
      answers = get_answers(question)

      socket = assign(socket, question: question, answers: answers)
      {:noreply, socket}
    else
      {:noreply, redirect(socket, to: ~p"/subjects/#{subject.id}")}
    end
  end

  def render_breadcrumb(assigns) do
    topic = Knowledge.get_topic!(assigns.topic_id)
    assigns = Map.put(assigns, :topic, topic)

    ~H"""
    <div class="h-14">
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
                href={~p"/subjects/#{@subject.id}/topics"}
                class="ml-1 text-sm font-medium text-gray-700 hover:text-green-600 md:ml-2 dark:text-gray-400 dark:hover:text-white"
              >
                <%= @subject.name %>
              </a>
            </div>
          </li>

          <li :if={@topic} aria-current="page">
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
                href={~p"/subjects/#{@subject.id}/topics/#{@topic.id}"}
                class="ml-1 text-sm font-medium text-gray-500 md:ml-2 dark:text-gray-400"
              >
                <%= @topic.name %>
              </a>
            </div>
          </li>
        </ol>
      </nav>
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
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <.render_breadcrumb subject={@subject} topic_id={@question.topic_id} />
    <.live_component
      module={AnswerQuestion}
      id="test-subject-answer-question"
      question={@question}
      answers={@answers}
    />
    """
  end
end
