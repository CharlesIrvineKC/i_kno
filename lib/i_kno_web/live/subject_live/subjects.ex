defmodule IKnoWeb.SubjectLive.Subjects do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(_params, session, socket) do
    user_token = Map.get(session, "user_token")

    is_super_user =
      if user_token do
        user = Accounts.get_user_by_session_token(user_token)
        user.id == 2
      else
        false
      end

    {:ok,
     assign(socket,
       is_super_user: is_super_user,
       # subjects: (if user, do: Knowledge.list_subjects_learning(user.id), else: []),
       subjects: Knowledge.list_subjects(),
       page_title: "IKno Subjects"
     )}
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
      <h2 class="mb-10 text-4xl font-extrabold dark:text-white">Learning</h2>
    </div>
    <div>
      <%= for subject <- @subjects do %>
        <.render_subject subject={subject} is_super_user={@is_super_user} />
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

  def render_subject(assigns) do
    ~H"""
    <div :if={@is_super_user || @subject.is_published} class="border border-gray-300 rounded my-2 p-2">
      <a href={~p"/subjects/#{@subject.id}"} class="font-medium text-blue-600 dark:text-blue-500 hover:underline">
        <%= @subject.name %>
      </a>
      <div><%= @subject.summary %></div>
    </div>
    """
  end
end
