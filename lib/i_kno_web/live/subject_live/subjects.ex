defmodule IKnoWeb.SubjectLive.Subjects do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  def mount(_parameters, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    is_super_user = user.id == 2
    {:ok, assign(socket, is_super_user: is_super_user, subjects: Knowledge.list_subjects())}
  end

  def handle_event("new", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/new")}
  end

  def handle_event("delete-subject", %{"subject-id" => subject_id}, socket) do
    subject_id = String.to_integer(subject_id)
    Knowledge.delete_subject_by_id(subject_id)
    {:noreply, assign(socket, :subjects, Knowledge.list_subjects())}
  end

  def render(assigns) do
    ~H"""
    <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
    <h2 class="mb-10 text-4xl font-extrabold dark:text-white">IKno Subjects</h2>
    <table class="mt-2 w-full text-sm text-left text-gray-500 dark:text-gray-400">
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
            <th scope="row" class="px-6 py-1 font-medium text-gray-900 whitespace-nowrap dark:text-white">
              <%= subject.name %>
            </th>
            <td class="px-6 py-1">
              <%= subject.summary %>
            </td>
            <td class="px-6 py-1">
              <a
                href={~p"/subjects/#{subject.id}"}
                class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
              >
                View
              </a>
              <a
                :if={@is_super_user}
                href={~p"/subjects/#{subject.id}/edit"}
                class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
              >
                Edit
              </a>
              <a
                :if={@is_super_user}
                phx-click="delete-subject"
                phx-value-subject-id={subject.id}
                href="#"
                class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
              >
                Delete
              </a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <button
      :if={@is_super_user}
      type="button"
      class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/new"}>New</a>
    </button>
    """
  end
end
