defmodule IKnoWeb.Components.AnswerEditor do
  use IKnoWeb, :live_component

  alias IKnoWeb.Highlighter
  alias IKno.Knowledge

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, assign(socket, is_editing: false)}
  end

  def handle_event("edit-answer", _, socket) do
    socket = assign(socket, is_editing: true)
    {:noreply, socket}
  end

  def handle_event("save-answer", %{"answer-input" => new_answer}, socket) do
    answer = socket.assigns.answer
    {:ok, answer} = Knowledge.update_answer(answer, %{answer: new_answer})
    socket = assign(socket, is_editing: false, answer: answer)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="w-full flex flex-row">
      <form class="w-full flex flex-row" phx-submit="save-answer" phx-target={@myself}>
        <div :if={!@is_editing} class="border rounded border-grey-900 p-2 w-full mr-4 mb-2">
          <p>
            <section class="markdown" id="answer-discription" phx-hook="ShowTopic">
              <%= Highlighter.highlight(Earmark.as_html!(@answer.answer)) |> Phoenix.HTML.raw() %>
            </section>
          </p>
        </div>
        <div :if={@is_editing} class="w-full mr-4">
          <input
            type="text"
            id="answer-input"
            name="answer-input"
            value={@answer.answer}
            class="m-1 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            placeholder="John"
            required
          />
        </div>
        <div :if={!@is_editing} class="mr-1 flex items-center">
          <input
            checked
            id="checked-checkbox"
            type="checkbox"
            value=""
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
          />
        </div>

        <button
          :if={!@is_editing}
          class="mr-1"
          type="button"
          phx-click="edit-answer"
          phx-target={@myself}
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-4 h-4"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L6.832 19.82a4.5 4.5 0 01-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 011.13-1.897L16.863 4.487zm0 0L19.5 7.125"
            />
          </svg>
        </button>

        <button :if={@is_editing} class="mr-1" type="submit">
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
        <button
          :if={!@is_editing}
          type="button"
          phx-click="delete-answer"
          phx-value-answer-id={@answer.id}
          phx-target={@parent_component}
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-4 h-4"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0"
            />
          </svg>
        </button>
      </form>
    </div>
    """
  end
end
