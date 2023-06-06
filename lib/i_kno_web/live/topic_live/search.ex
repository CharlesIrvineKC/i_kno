defmodule IKnoWeb.TopicLive.Search do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  def mount(%{"subject_id" => subject_id}, _session, socket) do
    subject_id = String.to_integer(subject_id)
    subject = Knowledge.get_subject!(subject_id)
    {:ok, assign(socket, subject: subject, topic: nil, topics: [], page_title: "Search: " <> subject.name)}
  end

  def handle_event("search", %{"topic-search" => search_string}, socket) do
    topics = Knowledge.find_topics(search_string, socket.assigns.subject.id)
    socket = assign(socket, topics: topics)
    {:noreply, socket}
  end

  def handle_event("view", %{"topic-id" => topic_id}, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{topic_id}")}
  end

  def handle_event("learn", %{"topic-id" => topic_id}, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{topic_id}/learn")}
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
            <a
              href={~p"/subjects/#{@subject.id}/topics"}
              class="ml-1 text-sm font-medium text-gray-700 hover:text-blue-600 md:ml-2 dark:text-gray-400 dark:hover:text-white"
            >
              <%= @subject.name %>
            </a>
          </div>
        </li>
        <li :if={@topic} aria-current="page">
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
              <%= @topic.name %>
            </span>
          </div>
        </li>
      </ol>
    </nav>
    """
  end

  def render_searchinput(assigns) do
    ~H"""
    <form phx-submit="search" class="w-80 inline-block float-right flex items-center">
      <label for="topic-search" class="sr-only">Search</label>
      <div class="relative w-full">
        <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
          <svg
            aria-hidden="true"
            class="w-5 h-5 text-gray-500 dark:text-gray-400"
            fill="currentColor"
            viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              fill-rule="evenodd"
              d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
              clip-rule="evenodd"
            >
            </path>
          </svg>
        </div>
        <input
          type="text"
          id="topic-search"
          name="topic-search"
          autofocus
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2.5  dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          placeholder="Topic Search"
          required
        />
      </div>
      <button
        type="submit"
        class="p-2.5 ml-2 text-sm font-medium text-white bg-blue-700 rounded-lg border border-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
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
    </form>
    """
  end

  def render_search_item(assigns) do
    ~H"""
    <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
        <%= @topic.name %>
    </h5>
    <p class="text-black dark:text-gray-400">
      <section class="markdown">
        <%= Earmark.as_html!(@topic.description) |> Phoenix.HTML.raw() %>
      </section>
    </p>
    <div class="mt-3 inline-flex rounded-md shadow-sm" role="group">
      <button
        type="button"
        phx-click="view"
        phx-value-topic-id={@topic.id}
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
      >
        View
      </button>
      <button
        type="button"
        phx-click="learn"
        phx-value-topic-id={@topic.id}
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
      >
        Learn
      </button>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="h-14 mb-10">
      <.render_breadcrumb subject={@subject} topic={@topic} />
      <.render_searchinput />
    </div>
    <ul
      :if={length(@topics) > 0}
      class="w-full text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white"
    >
      <li
        :for={topic <- @topics}
        class="w-full px-4 py-2 border-b border-gray-200 rounded-t-lg dark:border-gray-600"
      >
        <.render_search_item topic={topic} />
      </li>
    </ul>
    """
  end
end
