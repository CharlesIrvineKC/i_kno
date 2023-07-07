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
    question = Knowledge.get_question!(question_id)

    answers =
      if question.type == :multiple_choice do
        Knowledge.list_answers(question_id)
      else
        nil
      end

    {:noreply, assign(socket, current_question: question, answers: answers)}
  end

  def render_new_button(assigns) do
    ~H"""
    <div>
      <button
        type="button"
        class="text-blue-700 border border-blue-700 hover:bg-blue-700 hover:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-2.5 text-center inline-flex items-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white dark:focus:ring-blue-800 dark:hover:bg-blue-500"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          version="1.1"
          id="Capa_1"
          x="0px"
          y="0px"
          viewBox="0 0 512 512"
          style="enable-background:new 0 0 512 512;"
          xml:space="preserve"
          width="10"
          height="10"
        >
          <g>
            <path d="M480,224H288V32c0-17.673-14.327-32-32-32s-32,14.327-32,32v192H32c-17.673,0-32,14.327-32,32s14.327,32,32,32h192v192   c0,17.673,14.327,32,32,32s32-14.327,32-32V288h192c17.673,0,32-14.327,32-32S497.673,224,480,224z" />
          </g>
        </svg>
      </button>
    </div>
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
          class="font-medium text-blue-600 dark:text-blue-500 hover:underline"><%= question.question %></a>
    </div>
    """
  end

  def render_question(assigns) do
    ~H"""
    <div :if={@current_question}>
      <div class="p-2 m-2 border border-grey-200 rounded"><%= @current_question.question %></div>
      <div :for={answer <- @answers}><.render_answer answer={answer}/></div>
    </div>
    """
  end

  def render_answer(assigns) do
    ~H"""
    <div class="p-2 m-2 border border-grey-200 rounded"><%= @answer.answer %></div>
    """
  end

  def render(assigns) do
    ~H"""
    <dv>
      <!--.render_new_button /-->
      <.render_questions questions={@questions} myself={@myself} />
      <.render_question current_question={@current_question} answers={@answers} myself={@myself}/>
    </dv>
    """
  end
end
