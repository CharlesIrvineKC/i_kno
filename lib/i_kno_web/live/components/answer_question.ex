defmodule IKnoWeb.AnswerQuestion do
  use IKnoWeb, :live_component

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  alias IKnoWeb.Highlighter
  alias IKno.Knowledge

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    topic = Knowledge.get_topic!(socket.assigns.question.topic_id)
    subject = Knowledge.get_subject!(topic.subject_id)
    {:ok, assign(socket, is_editing: false, topic: topic, subject: subject)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3 class="mb-2 text-3xl font-bold dark:text-white"><%= @topic.name %></h3>
      <%= if @question.type == "multiple_choice" do %>
        <.render_multiple_choice question={@question} answers={@answers} />
      <% else %>
        <.render_true_false :if={@question.type == "true_false"} question={@question} answers={@answers} />
      <% end %>
    </div>
    """
  end

  def render_question_buttons(assigns) do
    ~H"""
    <button
      type="submit"
      class="mt-3 px-3 py-2 text-xs font-medium text-center text-white bg-green-700 rounded-lg hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      Submit
    </button>
    <button
      type="button"
      phx-click="stop-testing"
      class="mt-3 px-3 py-2 text-xs font-medium text-center text-white bg-green-700 rounded-lg hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      Stop Testing
    </button>
    """
  end

  def render_multiple_choice(assigns) do
    ~H"""
    <form phx-submit="submit-mc-answers">
      <div class="border rounded border-grey-900 p-5">
        <section class="markdown mb-5" id="topic-discription" phx-hook="MountAndUpdate">
          <%= Highlighter.highlight(Earmark.as_html!(@question.question)) |> Phoenix.HTML.raw() %>
        </section>
        <div>
          <div :for={answer <- @answers} class="flex items-center mb-2 ">
            <input
              id={"#{answer.id}"}
              name={"#{answer.id}"}
              type="checkbox"
              value="true"
              class="w-4 h-4 text-green-600 bg-gray-100 border-gray-300 rounded focus:ring-green-500 dark:focus:ring-green-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
            />
            <label
              for="default-checkbox"
              class="markdown ml-2 text-sm font-medium text-center text-gray-900 dark:text-gray-300"
              id={"answer-#{answer.id}"}
              phx-hook="MountAndUpdate"
            >
              <%= Highlighter.highlight(Earmark.as_html!(answer.answer)) |> Phoenix.HTML.raw() %>
            </label>
          </div>
        </div>
      </div>
      <.render_question_buttons />
    </form>
    """
  end

  def render_true_false(assigns) do
    ~H"""
    <form phx-submit="submit-tf-answer">
      <div class="border rounded border-grey-900 p-5">
        <section class="markdown mb-5" id="topic-discription" phx-hook="MountAndUpdate">
          <%= Highlighter.highlight(Earmark.as_html!(@question.question)) |> Phoenix.HTML.raw() %>
        </section>
        <div class="flex items-center mb-4">
          <input
            id="true-button"
            name="true?"
            type="radio"
            value="true"
            name="default-radio"
            class="w-4 h-4 text-green-600 bg-gray-100 border-gray-300 focus:ring-green-500 dark:focus:ring-green-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
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
            class="w-4 h-4 text-green-600 bg-gray-100 border-gray-300 focus:ring-green-500 dark:focus:ring-green-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
          />
          <label for="default-radio-2" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
            False
          </label>
        </div>
      </div>
      <.render_question_buttons />
    </form>
    """
  end
end
