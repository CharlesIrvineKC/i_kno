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
      <.render_breadcrumb subject={@subject} topic={@topic}/>
      <h3 class="mb-2 text-3xl font-bold dark:text-white"><%= @topic.name %></h3>
      <%= if @question.type == "multiple_choice" do %>
        <.render_multiple_choice question={@question} answers={@answers} />
      <% else %>
        <.render_true_false :if={@question.type == "true_false"} question={@question} answers={@answers} />
      <% end %>
    </div>
    """
  end

  def render_breadcrumb(assigns) do
    ~H"""
    <div class="h-14">
      <nav class="pt-3 inline-block " aria-label="Breadcrumb">
        <ol class="inline-flex items-center space-x-1 md:space-x-3">
          <li class="inline-flex items-center">
            <a
              href={~p"/subjects"}
              class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white"
            >
              <svg
                aria-hidden="true"
                class="w-4 h-4 mr-2"
                fill="currentColor"
                viewBox="0 0 20 20"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z">
                </path>
              </svg>
              Subjects
            </a>
          </li>
          <li>
            <div class="flex items-center">
              <svg
                aria-hidden="true"
                class="w-6 h-6 text-gray-400"
                fill="currentColor"
                viewBox="0 0 20 20"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  fill-rule="evenodd"
                  d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                  clip-rule="evenodd"
                >
                </path>
              </svg>
              <a
                href={~p"/subjects/#{@subject.id}/topics"}
                class="ml-1 text-sm font-medium text-gray-700 hover:text-blue-600 md:ml-2 dark:text-gray-400 dark:hover:text-white"
              >
                <%= @subject.name %>
              </a>
            </div>
          </li>

          <li :if={@topic} aria-current="page">
            <div class="flex items-center">
              <svg
                aria-hidden="true"
                class="w-6 h-6 text-gray-400"
                fill="currentColor"
                viewBox="0 0 20 20"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  fill-rule="evenodd"
                  d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                  clip-rule="evenodd"
                >
                </path>
              </svg>
              <a
                href={~p"/subjects/#{@subject.id}/topics/#{@topic.id}"} class="ml-1 text-sm font-medium text-gray-500 md:ml-2 dark:text-gray-400">
                <%= @topic.name %>
              </a>
            </div>
          </li>
        </ol>
      </nav>
      <button
        type="submit"
        phx-click="search"
        class="float-right p-2.5 ml-2 text-sm font-medium text-white bg-blue-700 rounded-lg border border-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        <svg
          class="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
          >
          </path>
        </svg>
        <span class="sr-only">Search</span>
      </button>
    </div>
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
              class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
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
