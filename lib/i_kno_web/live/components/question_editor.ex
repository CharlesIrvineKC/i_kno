defmodule IKnoWeb.Components.QuestionEditor do
  use IKnoWeb, :live_component

  alias IKno.Knowledge
  alias IKnoWeb.Components.AnswerEditor
  alias IKnoWeb.Highlighter

  def mount(socket) do
    {:ok, assign(socket, current_question: nil, answers: [])}
  end

  def update(assigns, socket) do
    topic = assigns.topic
    socket = assign(socket, assigns)
    questions = Knowledge.list_questions(topic.id)

    {:ok, assign(socket, questions: questions, is_editing: false)}
  end

  def handle_event("delete-answer", %{"answer-id" => answer_id}, socket) do
    answer = Knowledge.get_answer!(answer_id)
    Knowledge.delete_answer(answer)
    answers = Knowledge.list_answers(socket.assigns.current_question.id)
    {:noreply, assign(socket, answers: answers)}
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

  def handle_event("create-mc-question", _params, socket) do
    topic = socket.assigns.topic

    {:ok, new_question} =
      Knowledge.create_question(%{question: "New Question", topic_id: topic.id, type: :multiple_choice})

    questions = socket.assigns.questions ++ [new_question]

    {:noreply, assign(socket, questions: questions, current_question: new_question, answers: [])}
  end

  def handle_event("create-tf-question", _params, socket) do
    topic = socket.assigns.topic

    {:ok, new_question} =
      Knowledge.create_question(%{question: "New Question", topic_id: topic.id, type: :true_false})

    {:noreply, assign(socket, current_question: new_question, answers: [])}
  end

  def handle_event("new-answer", _, socket) do
    current_question = socket.assigns.current_question
    {:ok, new_answer} = Knowledge.create_answer(%{answer: "New Answer", question_id: current_question.id})
    answers = socket.assigns.answers ++ [new_answer]
    socket = assign(socket, answers: answers)
    {:noreply, socket}
  end

  def handle_event("edit-question", _, socket) do
    socket = assign(socket, is_editing: true)
    {:noreply, socket}
  end

  def handle_event("save-question", %{"question-input" => question_question}, socket) do
    question = socket.assigns.current_question
    {:ok, question} = Knowledge.update_question(question, %{question: question_question})
    questions = Knowledge.list_questions(socket.assigns.topic.id)
    socket = assign(socket, current_question: question, is_editing: false, questions: questions)
    {:noreply, socket}
  end

  def render_new_button(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="create-mc-question"
      phx-target={@myself}
      class="px-3 py-2 text-xs mb-5 font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      New Multiple Choice
    </button>
    <button
      type="button"
      phx-click="create-tf-question"
      phx-target={@myself}
      class="px-3 py-2 text-xs mb-5 font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      New True/False
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
    <div :if={@current_question}>
      <div class="mt-10">Question</div>
      <div class="p-2 rounded flex flex-row">
        <!-- Question Display -->
        <div :if={!@is_editing} class="border rounded border-grey-900 p-2 w-full mr-4 mb-2">
          <p>
            <section class="markdown" id="question-discription" phx-hook="ShowTopic">
              <%= Highlighter.highlight(Earmark.as_html!(@current_question.question)) |> Phoenix.HTML.raw() %>
            </section>
          </p>
        </div>
        <!-- Question Edit Buttom -->
        <button :if={!@is_editing} type="button" phx-click="edit-question" phx-target={@myself}>
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
        <form :if={@is_editing} class="flex flex-row w-full" phx-submit="save-question" phx-target={@myself}>
          <!-- Question Edit -->
          <div class="flex flex-row w-full">
            <input
              type="text"
              autofocus
              id="question-input"
              name="question-input"
              value={@current_question.question}
              class="m-1 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
              required
            />
          </div>
          <!-- Question Save Buttom -->
          <button type="submit">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="w-6 h-6"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
            </svg>
          </button>
        </form>
      </div>
      <!-- Display Answers -->
      <div>
        <div class="flex flex-row mb-2">
          <span>Answers</span>
          <!-- Create New Answer Button -->
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
        <div :for={answer <- @answers} class="flex flex-row ml-2">
          <.live_component
            module={AnswerEditor}
            id={"answer-editor-#{answer.id}"}
            parent_component={@myself}
            answer={answer}
            question={@current_question}
          />
        </div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <.render_new_button myself={@myself} />
      <.render_questions questions={@questions} myself={@myself} />
      <.render_question
        current_question={@current_question}
        answers={@answers}
        myself={@myself}
        is_editing={@is_editing}
      />
    </div>
    """
  end
end
