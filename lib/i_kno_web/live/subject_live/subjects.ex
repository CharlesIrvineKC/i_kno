defmodule IKnoWeb.SubjectLive.Subjects do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  def mount(_parameters, _session, socket) do
    {:ok, assign(socket, :subjects, Knowledge.list_subjects())}
  end

  def handle_event("new", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/new")}
  end

  def render(assigns) do
    ~H"""
    <div class="mb-10 pb-4 bg-white dark:bg-gray-900">
      <label for="table-search" class="sr-only">Search</label>
      <div class="relative mt-1">
        <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
          <svg
            class="w-5 h-5 text-gray-500 dark:text-gray-400"
            aria-hidden="true"
            fill="currentColor"
            viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              fill-rule="evenodd"
              d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
              clip-rule="evenodd"
            >
            </path>
          </svg>
        </div>
        <input
          type="text"
          id="table-search"
          class="block p-2 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg w-80 bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          placeholder="What would you like to know?"
        />
      </div>
    </div>
    <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
      <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
        <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
          <tr>
            <th scope="col" class="px-6 py-3">
              Subject name
            </th>
            <th scope="col" class="px-6 py-3">
              Summary
            </th>
            <th scope="col" class="px-6 py-3">
              Actions
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={subject <- @subjects}
            class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
          >
            <th
              scope="row"
              class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white"
            >
              <%= subject.name %>
            </th>
            <td class="px-6 py-4">
              <%= subject.summary %>
            </td>
            <td class="px-6 py-4">
              <a
                href={~p"/subjects/#{subject.id}"}
                class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
              >
                View
              </a>
              <a href={~p"/subjects/#{subject.id}/learn"} class="font-medium text-blue-600 dark:text-blue-500 hover:underline">
                Learn
              </a>
              <a href={~p"/subjects/#{subject.id}/edit"} class="font-medium text-blue-600 dark:text-blue-500 hover:underline">
                Edit
              </a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <button
      type="button"
      class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/new"}>New</a>
    </button>
    """
  end
end
