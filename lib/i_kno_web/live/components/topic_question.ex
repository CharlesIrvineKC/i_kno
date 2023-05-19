defmodule IKnoWeb.Components.TopicQuestion do
  use IKnoWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def update(_assigns, socket) do
    {:ok, assign(socket, take_question: false, question_posted: false)}
  end

  def handle_event("post-question", _, socket) do
    socket = assign(socket, take_question: false, question_posted: true )
    {:noreply, socket}
  end

  def handle_event("take-question", _, socket) do
    socket = assign(socket, take_question: !socket.assigns.take_question)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <form :if={@take_question} phx-submit="post-question" phx-target={@myself} class="mt-5">
        <div class="w-full mb-4 border border-gray-200 rounded-lg bg-gray-50 dark:bg-gray-700 dark:border-gray-600">
          <div class="px-4 py-2 bg-white rounded-t-lg dark:bg-gray-800">
            <textarea
              id="comment"
              rows="4"
              class="w-full px-0 text-sm text-gray-900 bg-white border-0 dark:bg-gray-800 focus:ring-0 dark:text-white dark:placeholder-gray-400"
              placeholder="Ask a question"
              required
            />
          </div>
          <div class="px-3 py-2 border-t dark:border-gray-600">
            <button
              type="submit"
              class="inline-flex items-center py-2.5 px-4 text-xs font-medium text-center text-white bg-blue-700 rounded-lg focus:ring-4 focus:ring-blue-200 dark:focus:ring-blue-900 hover:bg-blue-800"
            >
              Post your question
            </button>
          </div>
        </div>
      </form>
      <div>
        <button
          type="button"
          phx-click="take-question"
          phx-target={@myself}
          class="h-8 mt-2 px-3 py-2 text-xs text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          <%= if @take_question, do: "Cancel Question", else: "Ask Question" %>
        </button>
        <div
          :if={@question_posted}
          id="toast-success"
          class="flex items-center mt-6 w-full max-w-full p-4 mb-4 text-gray-500 bg-white rounded-lg shadow dark:text-gray-400 dark:bg-gray-800"
          role="alert"
        >
          <div class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-green-500 bg-green-100 rounded-lg dark:bg-green-800 dark:text-green-200">
            <svg
              aria-hidden="true"
              class="w-5 h-5"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
            <span class="sr-only">Check icon</span>
          </div>
          <div class="ml-3 px-6 text-sm font-normal">
            Your question was posted. Thanks! If we make a change to the topic as a result of your question, we will definitely get back to you. Otherwise, we may or may not, depending on the volume of questions that have been asked. Sorry.
          </div>
          <button
            type="button"
            class="ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex h-8 w-8 dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700"
            data-dismiss-target="#toast-success"
            aria-label="Close"
          >
            <span class="sr-only">Close</span>
            <svg
              aria-hidden="true"
              class="w-5 h-5"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
          </button>
        </div>
      </div>
    </div>
    """
  end
end