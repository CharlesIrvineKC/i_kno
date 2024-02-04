defmodule IKnoWeb.SubjectLive.New do
  alias IKno.Accounts
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Knowledge.Subject

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  def mount(_params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = if user_token, do: Accounts.get_user_by_session_token(user_token)
    {:ok, assign(socket, subject: %Subject{}, user: user)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects")}
  end

  def handle_event("save", subject_params, socket) do
    subject_params = Map.put(subject_params, "is_published", false)
    {:ok, subject} = Knowledge.create_subject(IO.inspect(subject_params))
    Accounts.create_subject_admin_by_email_id(subject.id, socket.assigns.user.email)
    {:noreply, redirect(socket, to: ~p"/subjects/#{subject.id}")}
  end

  def render(assigns) do
    ~H"""
    <div>
      <form phx-submit="save">
        <div class="mb-6">
          <label for="name" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            Name
          </label>
          <input
            type="text"
            id="name"
            name="name"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-green-500 focus:border-green-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-green-500 dark:focus:border-green-500"
          />
        </div>
        <div class="mb-6">
          <label for="summary" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            Summary
          </label>
          <input
            type="text"
            id="summary"
            name="summary"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-green-500 focus:border-green-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-green-500 dark:focus:border-green-500"
          />
        </div>
        <div class="mb-6">
          <label for="description" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            Description
          </label>
          <textarea
            id="description"
            name="description"
            rows="25"
            class="block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-green-500 focus:border-green-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-green-500 dark:focus:border-green-500"
          />
        </div>
        <button
          type="submit"
          class="text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
        >
          Save
        </button>
        <button
          type="button"
          phx-click="cancel"
          class="text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
        >
          Cancel
        </button>
      </form>
    </div>
    """
  end
end
