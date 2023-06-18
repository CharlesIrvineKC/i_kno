defmodule IKnoWeb.SubjectLive.ShowSubject do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(%{"subject_id" => subject_id}, session, socket) do
    user_token = Map.get(session, "user_token")
    user = if user_token, do: Accounts.get_user_by_session_token(user_token), else: nil

    is_super_user =
      if user_token do
        user = Accounts.get_user_by_session_token(user_token)
        user.id == 2
      else
        false
      end

    subject_id = String.to_integer(subject_id)
    subject = Knowledge.get_subject!(subject_id)
    admins = Accounts.get_admins(subject_id)

    is_admin =
      if user do
        Enum.any?(admins, fn admin -> elem(admin, 1) == user.id end)
      else
        false
      end

    edit_admins = false

    socket =
      assign(socket,
        subject: subject,
        page_title: subject.name,
        is_admin: is_admin,
        admins: admins,
        is_super_user: is_super_user,
        edit_admins: edit_admins,
        display_message: false,
        message: ""
      )

    {:ok, socket}
  end

  def handle_event("create-new-admin", %{"admin_email_id" => email_id}, socket) do
    subject_id = socket.assigns.subject.id
    Accounts.create_subject_admin_by_email_id(subject_id, email_id)
    admins = Accounts.get_admins(subject_id)
    socket = assign(socket, admins: admins)
    {:noreply, socket}
  end

  def handle_event("edit-admins", _, socket) do
    socket = assign(socket, edit_admins: !socket.assigns.edit_admins)
    {:noreply, socket}
  end

  def handle_event("delete-subject", _params, socket) do
    Knowledge.delete_subject_by_id(socket.assigns.subject.id)
    {:noreply, redirect(socket, to: ~p"/subjects")}
  end

  def handle_event("publish-subject", _, socket) do
    subject = socket.assigns.subject
    message = if subject.is_published, do: "Subject Un-Puplished", else: "Subject Published"
    Knowledge.update_subject(subject, %{:is_published => !subject.is_published})
    subject = Knowledge.get_subject!(subject.id)
    socket = assign(socket, subject: subject, display_message: true, message: message)
    {:noreply, socket}
  end

  def handle_event("close-message", _, socket) do
    socket = assign(socket, display_message: false)
    {:noreply, socket}
  end

  def handle_event("search", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/search")}
  end

  def render_searchbox(assigns) do
    ~H"""
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
    """
  end

  def render_breadcrumb(assigns) do
    ~H"""
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
            <span class="ml-1 text-sm font-medium text-gray-500 md:ml-2 dark:text-gray-400">
              <%= @subject.name %>
            </span>
          </div>
        </li>
      </ol>
    </nav>
    """
  end

  def render_buttons(assigns) do
    ~H"""
    <button
      data-popover-target="topics-popover"
      type="button"
      class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      <a href={~p"/subjects/#{@subject.id}/topics"}>Topics</a>
    </button>
    <div
      data-popover
      id="topics-popover"
      role="tooltip"
      class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity duration-300 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
    >
      <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
        <h3 class="font-semibold text-gray-900 dark:text-white">List of topics</h3>
      </div>
      <div class="px-3 py-2">
        <p>Press this button and IKno display all of the topics in this subject.</p>
      </div>
      <div data-popper-arrow></div>
    </div>

    <button
      data-popover-target="learn-popover"
      type="button"
      class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      <a href={~p"/subjects/#{@subject.id}/learn"}>Learn</a>
    </button>
    <div
      data-popover
      id="learn-popover"
      role="tooltip"
      class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity duration-300 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
    >
      <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
        <h3 class="font-semibold text-gray-900 dark:text-white">Learn this subject</h3>
      </div>
      <div class="px-3 py-2">
        <p>
          Press this button and IKno will start presenting topics in an optimal oder, depending on what you already know.
          <strong>Requires login.</strong>
        </p>
      </div>
      <div data-popper-arrow></div>
    </div>
    <button
      :if={@is_admin}
      type="button"
      class="mt-12 text-white bg-blue-700 hover:bg-blue-800 focus:outline-none text-white focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/#{@subject.id}/issues"}>Issues</a>
    </button>
    <button
      :if={@is_admin}
      type="button"
      class="mt-12 text-white bg-blue-700 hover:bg-blue-800 focus:outline-none text-white focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/#{@subject.id}/edit"}>Edit</a>
    </button>
    <.render_delete_button is_superuser={@is_superuser} />
    <button
      :if={@is_superuser}
      type="button"
      phx-click="publish-subject"
      class="mt-12 text-white bg-blue-700 hover:bg-blue-800 focus:outline-none text-white focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <%= if @subject.is_published, do: "Un-Publish", else: "Publish" %>
    </button>
    """
  end

  def render_delete_button(assigns) do
    ~H"""
    <button
      :if={@is_superuser}
      data-modal-target="popup-modal" data-modal-toggle="popup-modal"
      type="button"
      class="mt-12 text-white bg-blue-700 hover:bg-blue-800 focus:outline-none text-white focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      Delete
    </button>

    <div
      id="popup-modal"
      tabindex="-1"
      class="fixed top-0 left-0 right-0 z-50 hidden p-4 overflow-x-hidden overflow-y-auto md:inset-0 h-[calc(100%-1rem)] max-h-full"
    >
      <div class="relative w-full max-w-md max-h-full">
        <div class="relative bg-white rounded-lg shadow dark:bg-gray-700">
          <button
            type="button"
            class="absolute top-3 right-2.5 text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center dark:hover:bg-gray-800 dark:hover:text-white"
            data-modal-hide="popup-modal"
          >
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
            <span class="sr-only">Close modal</span>
          </button>
          <div class="p-6 text-center">
            <svg
              aria-hidden="true"
              class="mx-auto mb-4 text-gray-400 w-14 h-14 dark:text-gray-200"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              >
              </path>
            </svg>
            <h3 class="mb-5 text-lg font-normal text-gray-500 dark:text-gray-400">
              Are you sure you want to delete this subject?
            </h3>
            <button
              data-modal-hide="popup-modal"
              phx-click="delete-subject"
              type="button"
              class="text-white bg-red-600 hover:bg-red-800 focus:ring-4 focus:outline-none focus:ring-red-300 dark:focus:ring-red-800 font-medium rounded-lg text-sm inline-flex items-center px-5 py-2.5 text-center mr-2"
            >
              Yes, I'm sure
            </button>
            <button
              data-modal-hide="popup-modal"
              type="button"
              class="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-gray-200 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10 dark:bg-gray-700 dark:text-gray-300 dark:border-gray-500 dark:hover:text-white dark:hover:bg-gray-600 dark:focus:ring-gray-600"
            >
              No, cancel
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def render_subject(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
      <%= @subject.name %>
    </h1>
    <p class="mb-3 text-black dark:text-gray-400">
      <%= @subject.summary %>
    </p>
    <div class="mb-3 border rounded border-grey-900 p-3">
      <p class="text-black dark:text-gray-400">
        <section class="markdown">
          <%= Earmark.as_html!(@subject.description) |> Phoenix.HTML.raw() %>
        </section>
      </p>
    </div>
    """
  end

  def render_admins(assigns) do
    ~H"""
    <div>
      <a
        href="#"
        phx-click="edit-admins"
        class="inline-flex items-center text-sm font-medium text-lime-600 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white"
      >
        <%= if @edit_admins, do: "Close Admins", else: "Edit Admins" %>
      </a>
    </div>
    <div :if={@edit_admins} class="mt-3">
      Current Admins:
      <label :for={admin <- @admins}>
        (<%= elem(admin, 0) %>)
      </label>
      <form phx-submit="create-new-admin" class="my-5">
        <div>
          <label for="admin_email_id" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            New Admin Email ID
          </label>
          <input
            type="text"
            id="admin_email_id"
            name="admin_email_id"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            required
          />
        </div>
        <button
          type="submit"
          class="mt-2 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Submit
        </button>
      </form>
    </div>
    """
  end

  def render_message(assigns) do
    ~H"""
    <div
      :if={@display_message}
      id="toast-success"
      class="flex items-center w-full max-w-xs p-4 mb-4 text-gray-500 bg-white rounded-lg shadow dark:text-gray-400 dark:bg-gray-800"
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
      <div class="ml-3 text-sm font-normal"><%= @message %></div>
      <button
        type="button"
        phx-click="close-message"
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
    """
  end

  def render(assigns) do
    ~H"""
    <.render_message display_message={@display_message} message={@message} />
    <div class="h-14">
      <.render_breadcrumb subject={@subject} />
      <.render_searchbox />
    </div>
    <.render_subject subject={@subject} />
    <%= if @is_super_user do %>
      <.render_admins admins={@admins} edit_admins={@edit_admins} />
    <% end %>
    <.render_buttons subject={@subject} is_admin={@is_admin} is_superuser={@is_super_user} />
    """
  end
end
