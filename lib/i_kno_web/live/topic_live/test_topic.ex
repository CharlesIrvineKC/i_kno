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
      Knowledge.get_unanswered_topic_prereq_question(testing_topic.id, user.id)

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

    socket = assign(socket, unanswered_question: question)
    {:noreply, socket}
  end

  def handle_event("submit-tf-answer", %{"true?" => true?}, socket) do
    %{unanswered_question: question, user: user, subject: subject, testing_topic: testing_topic} =
      socket.assigns

    true? = String.to_atom(true?)
    status = if true? == question.is_correct, do: :passed, else: :failed

    Knowledge.create_user_question_status(%{
      status: status,
      question_id: question.id,
      user_id: user.id,
      topic_id: question.topic_id,
      subject_id: subject.id
    })

    question =
      Knowledge.get_unanswered_topic_prereq_question(testing_topic.id, user.id) ||
      Knowledge.get_unanswered_topic_question(testing_topic.id, user.id)

    IO.inspect(question, label: "question")

    answers =
      if question && question.type == "multiple_choice" do
        Knowledge.list_answers(question.id)
      else
        nil
      end

    socket = assign(socket, unanswered_question: question, answers: answers)
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
