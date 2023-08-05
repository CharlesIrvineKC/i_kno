defmodule IKnoWeb.SubjectLive.Edit do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  def mount(%{"subject_id" => id}, _session, socket) do
    subject = Knowledge.get_subject!(id)

    socket =
      assign(socket,
        subject: subject,
        page_title: "Edit: " <> subject.name
      )

    {:ok, socket}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}")}
  end

  def handle_event("save", subject_params, socket) do
    {:ok, subject} = Knowledge.update_subject(socket.assigns.subject, subject_params)
    socket = assign(socket, subject: subject)
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
            value={@subject.name}
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
            value={@subject.summary}
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
            class="w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-green-500 focus:border-green-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-green-500 dark:focus:border-green-500"
          ><%= @subject.description %>
          </textarea>
        </div>
        <button
          type="submit"
          class="text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
        >
          Save
        </button>
        <button
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
