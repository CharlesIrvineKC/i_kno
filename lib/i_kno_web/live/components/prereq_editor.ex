defmodule IKnoWeb.Components.PrereqEditor do
  use IKnoWeb, :live_component

  alias IKno.Knowledge

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    topic = assigns.topic
    prereqs = Knowledge.get_prereqs(topic.id)

    socket =
      socket
      |> assign(assigns)
      |> assign(prereqs: prereqs)
      |> assign(matches: [], keys: [], prefix: "")

    {:ok, socket}
  end

  def handle_event("delete-prereq", %{"prereq-topic-id" => prereq_topic_id}, socket) do
    Knowledge.delete_prereq(socket.assigns.topic.id, prereq_topic_id)
    prereqs = Knowledge.get_prereqs(socket.assigns.topic.id)
    socket = assign(socket, prereqs: prereqs)
    {:noreply, socket}
  end

  def handle_event("view", %{"prereq-topic-id" => prereq_topic_id}, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{prereq_topic_id}")}
  end

  def handle_event("suggest", %{"prefix" => prefix}, socket) do
    matches = Knowledge.suggest_prereqs(prefix, socket.assigns.subject.id)
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
    <div class="mt-20">
      <h2 class="mb-6 text-2xl font-extrabold dark:text-white">Prerequisite Topics</h2>
      <div class="relative overflow-x-auto">
        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
          <tbody>
            <tr :for={prereq <- @prereqs} class="bg-white dark:bg-gray-800">
              <td scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                <%= prereq.name %>
              </td>
              <td class="px-6 py-4">
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

      <form phx-change="suggest" phx-target={@myself} phx-submit="add-prerequisite">
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
            class="my-10 block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
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
