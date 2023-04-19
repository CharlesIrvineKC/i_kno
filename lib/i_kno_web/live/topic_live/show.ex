defmodule IKnoWeb.TopicLive.Show do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(%{"topic_id" => topic_id}, %{"user_token" => user_token}, socket) do
    topic_id = String.to_integer(topic_id)
    user = Accounts.get_user_by_session_token(user_token)
    topic = Knowledge.get_topic!(topic_id)
    is_known = Knowledge.get_known(topic_id, user.id)
    is_learning = Knowledge.get_learning(topic_id, user.id)
    socket = assign(socket, topic: topic, is_known: is_known, user: user, is_learning: is_learning)
    {:ok, socket}
  end

  def handle_event("understood", _, socket) do
    Knowledge.set_known(socket.assigns.topic.id, socket.assigns.user.id)
    socket = assign(socket, is_known: true)
    {:noreply, socket}
  end

  def handle_event("learn", _, socket) do
    Knowledge.set_learning(socket.assigns.topic.id, socket.assigns.user.id)
    socket = assign(socket, is_learning: true)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-4xl dark:text-white">
        <%= @topic.name %>
      </h1>
      <p class="text-black dark:text-gray-400">
        <section class="markdown">
          <%= Earmark.as_html!(@topic.description,
            escape: false,
            inner_html: true,
            compact_output: true
          )
          |> Phoenix.HTML.raw() %>
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
        :if={!@is_learning}
        phx-click="learn"
        class="mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Learn
      </button>
    </div>
    <div class="mt-20">
    <h2 class="mb-6 text-2xl font-extrabold dark:text-white">Prerequisite Topics</h2>
    <div class="relative overflow-x-auto">
        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
          <tbody>
            <tr class="bg-white dark:bg-gray-800">
              <td scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                Apple MacBook Pro 17
              </td>
              <td class="px-6 py-4">
                  <a href="#" class="font-medium text-blue-600 dark:text-blue-500 hover:underline">Delete</a>
              </td>
            </tr>
            <tr class="bg-white dark:bg-gray-800">
              <td scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                Apple MacBook Pro 17
              </td>
              <td class="px-6 py-4">
                  <a href="#" class="font-medium text-blue-600 dark:text-blue-500 hover:underline">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <form>
        <label for="default-search" class="mb-2 text-sm font-medium text-gray-900 sr-only dark:text-white">Search</label>
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
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z">
              </path>
            </svg>
          </div>
          <input
            type="search"
            id="default-search"
            class="mt-10 block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            placeholder="Search for New Prerequisite Topics"
            required
          />
          <button
            type="submit"
            class="text-white absolute right-2.5 bottom-2.5 bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            Search
          </button>
        </div>
      </form>
    </div>
    """
  end
end
