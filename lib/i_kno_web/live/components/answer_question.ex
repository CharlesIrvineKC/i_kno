defmodule IKnoWeb.AnswerQuestion do
  use IKnoWeb, :live_component

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  alias IKnoWeb.Highlighter

  def render(assigns) do
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

end
