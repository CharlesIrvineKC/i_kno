defmodule IKnoWeb.TopicLive.Topics do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  def mount(%{"subject_id" => subject_id}, _session, socket) do
    topics = Knowledge.list_subject_topics(subject_id)
    socket = assign(socket, topics: topics)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
          <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
              <th scope="col" class="px-6 py-3">
                Topic name
              </th>
              <th scope="col" class="px-6 py-3">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              :for={topic <- @topics}
              class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
            >
              <th
                scope="row"
                class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white"
              >
                <%= topic.name %>
              </th>
              <td class="px-6 py-4">
                <a
                  href={~p"/subjects/#{topic.subject_id}/topics/#{topic.id}"}
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  View
                </a>
                <a
                  href="#"
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Learn
                </a>
                <a
                  href={~p"/subjects/:subject_id/topics/#{topic.id}/edit"}
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Edit
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
