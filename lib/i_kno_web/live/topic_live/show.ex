defmodule IKnoWeb.TopicLive.Show do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    subject = Knowledge.get_subject!(subject_id)
    user = Accounts.get_user_by_session_token(user_token)

    socket =
      assign(socket,
        subject: subject,
        user: user,
        matches: [],
        keys: [],
        prefix: ""
      )

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :learn, _params) do
    subject_id = socket.assigns.subject.id
    user = socket.assigns.user
    topic = Knowledge.get_unknown_topic(subject_id, user.id)

    prereqs =
      if topic do
        Knowledge.get_prereqs(topic.id)
      else
        []
      end

    is_known =
      if topic do
        Knowledge.get_known(topic.id, user.id)
      else
        nil
      end

    assign(
      socket,
      topic: topic,
      is_known: is_known,
      prereqs: prereqs,
      is_learning: true
    )
  end

  defp apply_action(socket, :show, %{"topic_id" => topic_id}) do
    user = socket.assigns.user
    topic = Knowledge.get_topic!(topic_id)
    prereqs = Knowledge.get_prereqs(topic.id)
    is_known = Knowledge.get_known(topic.id, user.id)

    assign(
      socket,
      topic: topic,
      is_known: is_known,
      prereqs: prereqs,
      is_learning: false
    )
  end

  def handle_event("new", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/new")}
  end

  def handle_event("review", _, socket) do
    Knowledge.reset_subject_progress(socket.assigns.subject.id, socket.assigns.user.id)
    topic = Knowledge.get_unknown_topic(socket.assigns.subject.id, socket.assigns.user.id)
    prereqs = Knowledge.get_prereqs(topic.id)
    socket = assign(socket, topic: topic, prereqs: prereqs)
    {:noreply, socket}
  end

  def handle_event("delete-prereq", %{"prereq-topic-id" => prereq_topic_id}, socket) do
    Knowledge.delete_prereq(socket.assigns.topic.id, prereq_topic_id)
    prereqs = Knowledge.get_prereqs(socket.assigns.topic.id)
    socket = assign(socket, prereqs: prereqs)
    {:noreply, socket}
  end

  def handle_event("understood", _, socket) do
    Knowledge.set_known(socket.assigns.topic.id, socket.assigns.user.id)

    {topic, is_known} =
      if socket.assigns.is_learning do
        {
          Knowledge.get_unknown_topic(socket.assigns.subject.id, socket.assigns.user.id),
          false
        }
      else
        {socket.assigns.topic, true}
      end

    prereqs = if topic do Knowledge.get_prereqs(topic.id) else [] end

    socket = assign(socket, topic: topic, is_known: is_known, prereqs: prereqs)
    {:noreply, socket}
  end

  def handle_event("edit", _, socket) do
    topic = socket.assigns.topic
    {:noreply, redirect(socket, to: ~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/edit")}
  end

  def handle_event("learn", _, socket) do
    Knowledge.set_learning(socket.assigns.topic.id, socket.assigns.user.id)
    socket = assign(socket, is_learning: true)
    {:noreply, socket}
  end

  def handle_event("suggest", %{"prefix" => prefix}, socket) do
    matches = Knowledge.suggest_prereqs(prefix, socket.assigns.subject.id)
    keys = Map.keys(matches)
    {:noreply, assign(socket, matches: matches, keys: keys)}
  end

  def handle_event("add-prerequisite", %{"prefix" => topic_name}, socket) do
    prereq_topic_id = socket.assigns.matches[topic_name]
    topic_id = socket.assigns.topic.id
    Knowledge.create_prereq(%{topic_id: topic_id, prereq_id: prereq_topic_id})
    prereqs = Knowledge.get_prereqs(topic_id)
    {:noreply, assign(socket, matches: [], keys: [], prefix: "", prereqs: prereqs)}
  end

  def render(assigns) do
    ~H"""
    <%= if @topic == nil do %>
      <h1 class="mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
        Congradulations!
      </h1>
      <p class="mb-6 text-lg font-normal text-gray-500 lg:text-xl sm:px-16 xl:px-48 dark:text-gray-400">
        You have completed your review of <i><b><%= @subject.name %></b></i>. Click the button below if you would like to review this subject again.
      </p>
      <a
        phx-click="review"
        href="#"
        class="inline-flex items-center justify-center px-5 py-3 text-base font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-900"
      >
        Review
      </a>
    <% else %>
      <div>
        <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-4xl dark:text-white">
          <%= @topic.name %>
        </h1>
        <p class="text-black dark:text-gray-400">
          <section class="markdown">
            <%= Earmark.as_html!(@topic.description) |> Phoenix.HTML.raw() %>
          </section>
        </p>
        <button
          :if={!@is_known}
          phx-click="understood"
          class="mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Understood
        </button>
        <button
          phx-click="edit"
          class="mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Edit
        </button>
        <button
          phx-click="new"
          class="mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          New
        </button>
      </div>
      <div class="mt-20">
        <h2 class="mb-6 text-2xl font-extrabold dark:text-white">Prerequisite Topics</h2>
        <div class="relative overflow-x-auto">
          <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
            <tbody>
              <tr :for={prereq <- @prereqs} class="bg-white dark:bg-gray-800">
                <td scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                  <%= prereq.name %>
                </td>
                <td class="px-6 py-4">
                  <a
                    href="#"
                    phx-click="delete-prereq"
                    phx-value-prereq-topic-id={prereq.topic_id}
                    class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                  >
                    Delete
                  </a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <form phx-change="suggest" phx-submit="add-prerequisite">
          <label for="default-search" class="mb-2 text-sm font-medium text-gray-900 sr-only dark:text-white">
            Search
          </label>
          <div class="relative">
            <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
              <svg
                aria-hidden="true"
                class="w-5 h-5 text-gray-500 dark:text-gray-400"
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
            </div>
            <input
              type="search"
              name="prefix"
              value={@prefix}
              list="matches"
              phx-debounce="1000"
              required
              placeholder="Search for New Prerequisite Topics"
              class="mt-10 block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            />
            <button
              type="submit"
              class="text-white absolute right-2.5 bottom-2.5 bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
            >
              Add Prerequisite
            </button>
          </div>
        </form>

        <datalist id="matches">
          <option :for={key <- @keys} value={key}></option>
        </datalist>
      </div>
    <% end %>
    """
  end
end
