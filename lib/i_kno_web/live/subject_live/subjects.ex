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
    <div>
      <h2 class="mb-10 text-4xl font-extrabold dark:text-white">IKno Subjects</h2>
    </div>
    <div>
      <%= for subject <- @subjects do %>
        <.render_subject_summary subject={subject} />
      <% end %>
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

  def render_subject_summary(assigns) do
    ~H"""
    <div class="border border-gray-300 rounded my-2 p-2">
      <a href={~p"/subjects/#{@subject.id}"} class="font-medium text-blue-600 dark:text-blue-500 hover:underline">
        <%= @subject.name %>
      </a>
      <div><%= @subject.summary %></div>
    </div>
    """
  end
end
