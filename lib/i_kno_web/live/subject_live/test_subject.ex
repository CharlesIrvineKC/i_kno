defmodule IKnoWeb.SubjectLive.TestSubject do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts
  alias IKnoWeb.AnswerQuestion

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    question = Knowledge.get_unanswered_question(subject_id, user.id)

    if question do
      answers = get_answers(question)

      socket = assign(socket, question: question, answers: answers, subject_id: subject_id, user: user)
      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/subjects/#{subject_id}/topics")}
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

    if question do
      answers = get_answers(question)

      socket = assign(socket, question: question, answers: answers)
      {:noreply, socket}
    else
      {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject_id}/topics")}
    end
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

    if question do
      answers = get_answers(question)

      socket = assign(socket, question: question, answers: answers)
      {:noreply, socket}
    else
      {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject_id}/topics")}
    end
  end

  def render(assigns) do
    ~H"""
      <.live_component
        module={AnswerQuestion}
        id="test-subject-answer-question"
        question={@question}
        answers={@answers}
      />
    """
  end
end
