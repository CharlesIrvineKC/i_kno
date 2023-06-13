defmodule IKnoWeb.Components.PrereqEditor do
  use IKnoWeb, :live_component

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  alias IKno.Knowledge

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    topic = assigns.topic
    prereqs = Knowledge.get_topic_prereqs(topic.id)

    socket =
      socket
      |> assign(assigns)
      |> assign(prereqs: prereqs)
      |> assign(matches: [], keys: [], prefix: "", cycle: false, search_all_subjects: false)

    {:ok, socket}
  end

  def handle_event("toggle-search-all-subjects", _, socket) do
    socket = assign(socket,search_all_subjects: !socket.assigns.search_all_subjects)

    {:noreply, socket}
  end

  def handle_event("delete-prereq", %{"prereq-topic-id" => prereq_topic_id}, socket) do
    prereq_topic_id = String.to_integer(prereq_topic_id)
    Knowledge.delete_prereq(socket.assigns.topic.id, prereq_topic_id)
    prereqs = Knowledge.get_topic_prereqs(socket.assigns.topic.id)
    socket = assign(socket, prereqs: prereqs)
    {:noreply, socket}
  end

  def handle_event("view", %{"prereq-topic-id" => prereq_topic_id}, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{prereq_topic_id}")}
  end

  def handle_event("suggest", %{"prefix" => prefix}, socket) do

    matches =
      if socket.assigns.search_all_subjects do
        Knowledge.suggest_prereqs(prefix, :all)
      else
        Knowledge.suggest_prereqs(prefix, socket.assigns.subject.id)
      end

    keys = Map.keys(matches)
    {:noreply, assign(socket, matches: matches, keys: keys)}
  end

  def handle_event("acknowledge-cycle", _, socket) do
    socket = assign(socket, cycle: false)
    {:noreply, socket}
  end

  def handle_event("add-prerequisite", %{"prefix" => topic_name}, socket) do
    prereq_topic_id = socket.assigns.matches[topic_name]
    topic_id = socket.assigns.topic.id
    result = Knowledge.create_prereq(%{topic_id: topic_id, prereq_id: prereq_topic_id})

    case result do
      :ok ->
        prereqs = Knowledge.get_topic_prereqs(topic_id)
        {:noreply, assign(socket, matches: [], keys: [], prefix: "", prereqs: prereqs)}

      cycle ->
        message = create_cycle_message(cycle)
        {:noreply, assign(socket, matches: [], keys: [], prefix: "", cycle: message)}
    end
  end

  def create_cycle_message([]), do: " <b> is a cycle<b>."

  def create_cycle_message([[_id, topic_name] | rest]) do
    if rest == [] do
      topic_name <> ":" <> create_cycle_message(rest)
    else
      topic_name <> " -> " <> create_cycle_message(rest)
    end
  end

  def render_prereqs(assigns) do
    ~H"""
    <div class="relative overflow-x-auto">
      <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
        <tbody>
          <tr :for={prereq <- @prereqs} class="bg-white dark:bg-gray-800">
            <td scope="row" class="px-6 py-1 font-medium text-gray-900 whitespace-nowrap dark:text-white">
              <a
                href={~p"/subjects/#{@topic.subject_id}/topics/#{prereq.topic_id}"}
                phx-target={@myself}
                class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
              >
                <%= prereq.name %>
              </a>
            </td>
            <td class="px-6 py-1">
              <a
                href="#"
                phx-click="delete-prereq"
                phx-value-prereq-topic-id={prereq.topic_id}
                phx-target={@myself}
                class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
              >
                Delete
              </a>
              <a
                href="#"
                phx-click="view"
                phx-value-prereq-topic-id={prereq.topic_id}
                phx-target={@myself}
                class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
              >
                View
              </a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def render_input_form(assigns) do
    ~H"""
    <form phx-change="suggest" phx-target={@myself} phx-submit="add-prerequisite">
      <div class="relative">
        <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
          <svg
            aria-hidden="true"
            class="w-5 h-5 text-gray-500 dark:text-gray-400"
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
        </div>
        <input
          type="search"
          name="prefix"
          value={@prefix}
          list="matches"
          phx-debounce="1000"
          required
          placeholder="Search for New Prerequisite Topics"
          class="mt-10 mb-2 block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        />

        <datalist id="matches">
          <option :for={key <- @keys} value={key}></option>
        </datalist>

        <button
          type="submit"
          class="text-white absolute right-2.5 bottom-2.5 bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-1 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Add Prerequisite
        </button>
      </div>
    </form>

    <div class="flex items-center">
      <input
        checked={@search_all_subjects}
        phx-click="toggle-search-all-subjects"
        phx-target={@myself}
        id="checked-checkbox"
        type="checkbox"
        value=""
        class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
      />
      <label for="checked-checkbox" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
        Search All Subjects
      </label>
    </div>
    """
  end

  def render_cycle_alert(assigns) do
    ~H"""
    <div
      :if={@cycle}
      id="toast-default"
      class="flex items-center w-full max-w-xl p-4 text-gray-500 bg-white rounded-lg shadow dark:text-gray-400 dark:bg-gray-800"
      role="alert"
    >
      <div class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-blue-500 bg-blue-100 rounded-lg dark:bg-blue-800 dark:text-blue-200">
        <svg
          aria-hidden="true"
          class="w-5 h-5"
          fill="currentColor"
          viewBox="0 0 20 20"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fill-rule="evenodd"
            d="M12.395 2.553a1 1 0 00-1.45-.385c-.345.23-.614.558-.822.88-.214.33-.403.713-.57 1.116-.334.804-.614 1.768-.84 2.734a31.365 31.365 0 00-.613 3.58 2.64 2.64 0 01-.945-1.067c-.328-.68-.398-1.534-.398-2.654A1 1 0 005.05 6.05 6.981 6.981 0 003 11a7 7 0 1011.95-4.95c-.592-.591-.98-.985-1.348-1.467-.363-.476-.724-1.063-1.207-2.03zM12.12 15.12A3 3 0 017 13s.879.5 2.5.5c0-1 .5-4 1.25-4.5.5 1 .786 1.293 1.371 1.879A2.99 2.99 0 0113 13a2.99 2.99 0 01-.879 2.121z"
            clip-rule="evenodd"
          >
          </path>
        </svg>
        <span class="sr-only">Fire icon</span>
      </div>
      <div class="ml-3 text-sm font-normal"><%= Phoenix.HTML.raw(@cycle) %></div>
      <button
        type="button"
        phx-click="acknowledge-cycle"
        phx-target={@myself}
        class="ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex h-8 w-8 dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700"
        data-dismiss-target="#toast-default"
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
    """
  end

  def render(assigns) do
    ~H"""
    <div class="mt-20">
      <h2 class="mb-6 text-2xl font-extrabold dark:text-white">Prerequisite Topics</h2>
      <.render_prereqs prereqs={@prereqs} topic={@topic} myself={@myself} />
      <.render_input_form
        myself={@myself}
        prefix={@prefix}
        keys={@keys}
        search_all_subjects={@search_all_subjects}
      />
      <.render_cycle_alert cycle={@cycle} />
    </div>
    """
  end
end
