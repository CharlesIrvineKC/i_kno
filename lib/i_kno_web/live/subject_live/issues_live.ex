defmodule IKnoWeb.IssuesLive do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  def mount(%{"subject_id" => subject_id}, _session, socket) do
    issues = Knowledge.get_issues_by_subject_id(subject_id)
    subject_name = Knowledge.get_subject_name(subject_id)

    socket =
      assign(socket,
        subject_id: subject_id,
        issues: issues,
        subject_name: subject_name
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= for issue <- @issues do %>
      <.render_issue issue={issue} subject_name={@subject_name} />
    <% end %>
    """
  end

  def render_issue(assigns) do
    ~H"""
    <div class="max-w-full p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700">
      <a href="#">
        <h5 class="mb-2 text-2xl font-semibold tracking-tight text-gray-900 dark:text-white">
          <%= @issue.summary %>
        </h5>
      </a>
      <p class="mb-3 font-normal text-gray-500 dark:text-gray-400">
        <%= @issue.description %>
      </p>
      <a
        href={~p"/subjects/#{@issue.subject_id}/topics/#{@issue.topic_id}"}
        class="inline-flex items-center text-blue-600 hover:underline"
      >
        <%= @subject_name %> : <%= Knowledge.get_topic_name(@issue.topic_id) %>
        <svg class="w-5 h-5 ml-2" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
          <path d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z">
          </path>
          <path d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z"></path>
        </svg>
      </a>
    </div>
    """
  end
end
