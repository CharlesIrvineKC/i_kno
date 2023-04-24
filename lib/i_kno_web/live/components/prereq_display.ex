defmodule IKnoWeb.Components.PrereqDisplay do
  use IKnoWeb, :live_component

  alias IKno.Knowledge

  def handle_event("suggest", %{"prefix" => prefix}, socket) do
    matches = Knowledge.suggest_prereqs(prefix, socket.assigns.topic.subject_id)
    keys = Map.keys(matches)
    {:noreply, assign(socket, matches: matches, keys: keys)}
  end

  def handle_event("add-prerequisite", %{"prefix" => topic_name}, socket) do
    prereq_topic_id = socket.assigns.matches[topic_name]
    topic_id = socket.assigns.topic.id
    Knowledge.create_prereq(%{topic_id: topic_id, prereq_id: prereq_topic_id})
    prereqs = Knowledge.get_prereqs(topic_id)
    {:noreply, assign(socket, matches: [], keys: [], prefix: "", prereqs: prereqs)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <form phx-change="suggest" phx-submit="add-prerequisite">
        <label for="default-search" class="mb-2 text-sm font-medium text-gray-900 sr-only dark:text-white">
          Search
        </label>
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
            class="mt-10 block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          />
          <button
            type="submit"
            class="text-white absolute right-2.5 bottom-2.5 bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            Add Prerequisite
          </button>
        </div>
      </form>

      <datalist id="matches">
        <option :for={key <- @keys} value={key}></option>
      </datalist>
    </div>
    """
  end
end
