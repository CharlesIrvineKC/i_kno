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
        subject_name: subject_name,
        status: :open
      )

    {:ok, socket}
  end

  def handle_event("close", %{"issue_id" => issue_id, "resolution" => resolution}, socket) do
    issue = Enum.find(socket.assigns.issues, &(&1.id == String.to_integer(issue_id)))
    Knowledge.update_issue(issue, %{status: :closed, resolution: resolution})
    issues = Knowledge.get_issues_by_subject_id(socket.assigns.subject_id)
    socket = assign(socket, issues: issues)
    {:noreply, socket}
  end

  def handle_event("toggle-status",  %{"status" => status}, socket) do
    socket = assign(socket, status: String.to_atom(status))
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-4xl dark:text-white">
      <%= @subject_name %> Issues
    </h1>
    <div class="flex mb-2">
      <div class="flex items-center mr-4">
        <input
          checked={@status == :open}
          phx-click="toggle-status"
          phx-value-status="open"
          id="inline-radio"
          type="radio"
          value=""
          name="inline-radio-group"
          class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
        />
        <label for="inline-radio" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
          Open
        </label>
      </div>
      <div class="flex items-center mr-4">
        <input
        checked={@status == :closed}
          phx-click="toggle-status"
          phx-value-status="closed"
          id="inline-2-radio"
          type="radio"
          value=""
          name="inline-radio-group"
          class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
        />
        <label for="inline-2-radio" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
          Closed
        </label>
      </div>
    </div>

    <%= for issue <- @issues do %>
      <%= if issue.status == @status do %>
        <.render_issue issue={issue} subject_name={@subject_name} />
      <% end %>
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
        Topic Name: <%= Knowledge.get_topic_name(@issue.topic_id) %>
        <svg class="w-5 h-5 ml-2" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
          <path d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z">
          </path>
          <path d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z"></path>
        </svg>
      </a>
      <div class="mt-5">
        <form :if={@issue.status == :open} phx-submit="close">
          <textarea
            id="resolution"
            name="resolution"
            rows="4"
            required
            class="p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            placeholder="Describe resolution..."
          ><%= @issue.resolution %></textarea>
          <input type="hidden" id="issue_id" name="issue_id" value={@issue.id} />
          <button
            type="submit"
            class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mt-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          >
            <%= if @issue.status == :open, do: "Close", else: "Re-Open" %>
          </button>
        </form>
        <div :if={@issue.status == :closed}>
        <label class="text-gray-500 mb-1">Resolution:</label>
        <div class="border border-gray-300 rounded p-2">
          <p><%= @issue.resolution %></p>
        </div>
        </div>
      </div>
    </div>
    """
  end
end
