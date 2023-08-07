defmodule IKnoWeb.TopicLive.TestTopic do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts
  alias IKnoWeb.AnswerQuestion

  def mount(%{"subject_id" => subject_id, "topic_id" => topic_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    testing_topic = Knowledge.get_topic!(String.to_integer(topic_id))
    subject = Knowledge.get_subject!(subject_id)
    user = Accounts.get_user_by_session_token(user_token)

    unanswered_question =
      Knowledge.get_unanswered_topic_question(testing_topic.id, user.id)

    if unanswered_question do
      answers =
        if unanswered_question && unanswered_question.type == "multiple_choice" do
          Knowledge.list_answers(unanswered_question.id)
        else
          nil
        end

      socket =
        assign(
          socket,
          subject: subject,
          user: user,
          testing_topic: testing_topic,
          unanswered_question: unanswered_question,
          answers: answers,
          page_title: "Test: " <> testing_topic.name
        )

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/subjects/#{subject.id}/topics")}
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

  def handle_event("review-topic", _, socket) do
    %{testing_topic: topic, subject: subject, user: user} = socket.assigns
    Knowledge.reset_learn_topic_progress(topic.id, user.id)
    {:noreply, redirect(socket, to: ~p"/subjects/#{subject.id}/topics/#{topic.id}/learn")}
  end

  def handle_event("retake-test", _, socket) do
    %{testing_topic: testing_topic, user: user} = socket.assigns

    Knowledge.delete_incorrect_question_records(testing_topic.id, user.id)

    unanswered_question =
      Knowledge.get_unanswered_topic_question(testing_topic.id, user.id)

    answers =
      if unanswered_question && unanswered_question.type == "multiple_choice" do
        Knowledge.list_answers(unanswered_question.id)
      else
        nil
      end

    socket =
      assign(
        socket,
        unanswered_question: unanswered_question,
        answers: answers,
        page_title: "Test: " <> testing_topic.name
      )

    {:noreply, socket}
  end

  def handle_event("stop-testing", _, socket) do
    {:noreply,
     redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{socket.assigns.testing_topic}")}
  end

  def handle_event("submit-mc-answers", params, socket) do
    answers = socket.assigns.answers

    passed? =
      answers
      |> Enum.map(fn answer -> is_correct(answer, params) end)
      |> Enum.reduce(fn bool, acc -> bool && acc end)

    status = if passed?, do: :passed, else: :failed

    process_event(status, socket)
  end

  def handle_event("submit-tf-answer", %{"true?" => true?}, socket) do
    question = socket.assigns.question

    true? = String.to_atom(true?)
    status = if true? == question.is_correct, do: :passed, else: :failed

    process_event(status, socket)
  end

  def process_event(status, socket) do
    Knowledge.create_user_question_status(%{
      status: status,
      question_id: socket.assigns.unanswered_question.id,
      user_id: socket.assigns.user.id,
      topic_id: socket.assigns.unanswered_question.topic_id,
      subject_id: socket.assigns.subject.id
    })

    question =
      Knowledge.get_unanswered_topic_question(socket.assigns.testing_topic.id, socket.assigns.user.id)

    if question do
      answers =
        if question && question.type == "multiple_choice" do
          Knowledge.list_answers(question.id)
        else
          nil
        end

      socket =
        assign(socket,
          unanswered_question: question,
          answers: answers
        )

      {:noreply, socket}
    else
      {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics")}
    end
  end

  def render_subject_test_complete(assigns) do
    ~H"""
    <h2 class="mb-4 mt-5 text-lg font-semibold text-gray-900 dark:text-white">
      Testing Complete for Topic: <%= @topic.name %>
    </h2>
    <ul class="mt-2 mb-4 max-w-md space-y-1 text-gray-500 list-disc list-inside dark:text-gray-400">
      <li>
        Correct Answers: 10
      </li>
      <li>
        Incorrect Answers: 2
      </li>
    </ul>
    <button
      type="button"
      phx-click="review-topic"
      class="mt-3 text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 focus:outline-none dark:focus:ring-green-800"
    >
      Review Topic
    </button>
    <button
      type="button"
      phx-click="retake-test"
      class="mt-3 text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 focus:outline-none dark:focus:ring-green-800"
    >
      Re-take Test
    </button>
    """
  end

  def render_breadcrumb(assigns) do
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
    <.render_breadcrumb subject={@subject} topic={@testing_topic} />
    <.live_component
      module={AnswerQuestion}
      id="test-topic-answer-question"
      question={@unanswered_question}
      answers={@answers}
    />
    """
  end
end
