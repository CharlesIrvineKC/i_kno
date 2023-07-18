defmodule IKnoWeb.TopicLive.TestTopic do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  alias IKnoWeb.AnswerQuestion

  def mount(%{"subject_id" => subject_id, "topic_id" => topic_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    testing_topic = Knowledge.get_topic!(String.to_integer(topic_id))
    IO.inspect(testing_topic, label: "testing_topic")
    subject = Knowledge.get_subject!(subject_id)
    user = Accounts.get_user_by_session_token(user_token)

    unknown_topic_id = Knowledge.get_next_unknown_topic_by_topic(subject_id, testing_topic.id, user.id)

    unknown_topic =
      if unknown_topic_id != nil, do: Knowledge.get_topic!(unknown_topic_id), else: testing_topic

    IO.inspect(unknown_topic, label: "unknown_topic")
    unanswered_question = Knowledge.get_unanswered_topic_question(unknown_topic.id, user.id)
    IO.inspect(unanswered_question, label: "unanswered_question")

    answers =
      if unanswered_question && unanswered_question.type == "multiple_choice" do
        Knowledge.list_answers(unanswered_question.id)
      else
        nil
      end

    IO.inspect(answers, label: "answers")

    socket =
      assign(
        socket,
        subject: subject,
        user: user,
        testing_topic: testing_topic,
        unknown_topic: unknown_topic,
        unanswered_question: unanswered_question,
        answers: answers,
        page_title: "Test: " <> testing_topic.name
      )

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
    %{answers: answers, unanswered_question: question, user: user, subject: subject} = socket.assigns

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

    socket = assign(socket, question: question)
    {:noreply, socket}
  end

  def handle_event("submit-tf-answer", %{"true?" => true?}, socket) do
    IO.inspect(socket.assigns)
    %{unanswered_question: question, user: user, subject: subject} = socket.assigns
    true? = String.to_atom(true?)
    status = if true? == question.is_correct, do: :passed, else: :failed

    Knowledge.create_user_question_status(%{
      status: status,
      question_id: question.id,
      user_id: user.id,
      topic_id: question.topic_id,
      subject_id: subject.id
    })

    question = Knowledge.get_unanswered_topic_question(socket.assigns.unknown_topic.id, user.id)
    socket = assign(socket, unanswered_question: question)

    {:noreply, socket}
  end

  def render_subject_test_complete(assigns) do
    ~H"""
    <h1>Subject Test Complete</h1>
    """
  end

  def render(assigns) do
    ~H"""
    <%= if @unanswered_question do %>
      <.live_component
        module={AnswerQuestion}
        id="test-topic-answer-question"
        question={@unanswered_question}
        answers={@answers}
      />
    <% else %>
      <.render_subject_test_complete />
    <% end %>
    """
  end
end
