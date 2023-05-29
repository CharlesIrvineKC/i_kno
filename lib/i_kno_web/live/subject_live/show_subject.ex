defmodule IKnoWeb.SubjectLive.ShowSubject do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    subject_id = String.to_integer(subject_id)
    admins = Accounts.get_admins(subject_id)
    is_admin = Enum.any?(admins, &(elem(&1, 1) == user.id))
    is_super_user = user.id == 2

    socket =
      assign(socket,
        subject: Knowledge.get_subject!(subject_id),
        is_admin: is_admin,
        admins: admins,
        is_super_user: is_super_user
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
        </p>
      </div>
      <div data-popper-arrow></div>
    </div>
    <button
      :if={@is_admin}
      type="button"
      class="mt-12 text-white bg-blue-700 hover:bg-blue-800 focus:outline-none text-white focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/#{@subject.id}/edit"}>Edit</a>
    </button>
    <button
      :if={@is_admin}
      type="button"
      class="mt-12 text-white bg-blue-700 hover:bg-blue-800 focus:outline-none text-white focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/#{@subject.id}/issues"}>Issues</a>
    </button>
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
    <div class="mb-5 border rounded border-grey-900 p-3">
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
    """
  end

  def render(assigns) do
    ~H"""
    <.render_subject subject={@subject} />
    <%= if @is_super_user do %>
      <.render_admins admins={@admins} />
    <% end %>
    <.render_buttons subject={@subject} is_admin={@is_admin} />
    """
  end
end
