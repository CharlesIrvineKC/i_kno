defmodule IKnoWeb.Components.QuestionEditor do
  use IKnoWeb, :live_component

  alias IKno.Knowledge

  def mount(socket) do
    {:ok, assign(socket, current_question: nil, answers: nil)}
  end

  def update(assigns, socket) do
    topic = assigns.topic
    socket = assign(socket, assigns)
    questions = Knowledge.list_questions(topic.id)

    {:ok, assign(socket, questions: questions)}
  end

  def handle_event("edit-question", %{"question-id" => question_id}, socket) do
    current_question = socket.assigns.current_question
    question_id = String.to_integer(question_id)

    if !current_question || current_question.id != question_id do
      question = Knowledge.get_question!(question_id)

      answers =
        if question.type == :multiple_choice do
          Knowledge.list_answers(question_id)
        else
          nil
        end

      {:noreply, assign(socket, current_question: question, answers: answers)}
    else
      {:noreply, assign(socket, current_question: nil, answers: nil)}
    end
  end

  def handle_event("create-question", _params, socket) do
    topic = socket.assigns.topic

    {:ok, new_question} =
      Knowledge.create_question(%{question: "New Question", topic_id: topic.id, type: :multiple_choice})

    {:noreply, assign(socket, current_question: new_question, answers: [])}
  end

  def handle_event("new-answer", _, socket) do
    current_question = socket.assigns.current_question
    {:ok, new_answer} = Knowledge.create_answer(%{answer: "New Answer", question_id: current_question.id})
    answers = socket.assigns.answers ++ [new_answer]
    socket = assign(socket, answers: answers)
    {:noreply, socket}
  end

  def render_new_button(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="create-question"
      phx-target={@myself}
      class="px-3 py-2 text-xs mb-5 font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      New Question
    </button>
    """
  end

  def render_questions(assigns) do
    ~H"""
    <div :for={question <- @questions} class="relative overflow-x-auto">
      <a
        phx-click="edit-question"
        phx-target={@myself}
        phx-value-question-id={question.id}
        href="#"
        class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
      >
        <%= question.question %>
      </a>
    </div>
    """
  end

  def render_question(assigns) do
    ~H"""
    <div :if={@current_question} class="mt-10 p-2 m-2 border border-grey-200 rounded">
      <div>Question</div>
      <div class="flex flex-row">
        <input
          type="text"
          readonly={true}
          id={"question-input-#{@current_question.id}"}
          value={@current_question.question}
          class="m-1 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          placeholder="John"
          required
        />
        <button type="button">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-6 h-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L6.832 19.82a4.5 4.5 0 01-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 011.13-1.897L16.863 4.487zm0 0L19.5 7.125"
            />
          </svg>

          <span class="sr-only">Icon description</span>
        </button>
      </div>
      <div class="flex flex-row">
        <span>Answers</span>
        <button class="ml-5" type="button" phx-click="new-answer" phx-target={@myself}>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-6 h-6"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
          </svg>
        </button>
      </div>
      <div class="flex flex-row" :for={answer <- @answers}><.render_answer answer={answer} /></div>
    </div>
    """
  end

  def render_answer(assigns) do
    ~H"""
      <div class="w-full mr-4">
        <input
          type="text"
          readonly={true}
          id={"answer-input-#{@answer.id}"}
          value={@answer.answer}
          class="m-1 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          placeholder="John"
          required
        />
      </div>
      <button type="button" phx-click="edit-answer" phx-value-answer-id={@answer.id}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="w-6 h-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L6.832 19.82a4.5 4.5 0 01-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 011.13-1.897L16.863 4.487zm0 0L19.5 7.125"
          />
        </svg>
      </button>
    """
  end

  def render(assigns) do
    ~H"""
    <dv>
      <.render_new_button myself={@myself} />
      <.render_questions questions={@questions} myself={@myself} />
      <.render_question current_question={@current_question} answers={@answers} myself={@myself} />
    </dv>
    """
  end
end
