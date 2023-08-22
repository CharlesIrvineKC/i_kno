defmodule IKnoWeb.TopicLive.LearnTopic do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  alias IKnoWeb.Components.TopicIssue
  alias IKnoWeb.Highlighter

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  def mount(%{"subject_id" => subject_id, "topic_id" => topic_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    learning_topic = Knowledge.get_topic!(String.to_integer(topic_id))
    subject = Knowledge.get_subject!(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    is_admin = Accounts.is_admin(subject_id, user.id)

    unknown_topic_id = Knowledge.get_next_unknown_topic_by_topic(subject_id, learning_topic.id, user.id)

    unknown_topic =
      if unknown_topic_id != nil, do: Knowledge.get_topic!(unknown_topic_id), else: learning_topic

    socket =
      assign(
        socket,
        subject: subject,
        user: user,
        is_admin: is_admin,
        learning_topic: learning_topic,
        unknown_topic: unknown_topic,
        visited_topics: [unknown_topic],
        page_title: "Learn: " <> unknown_topic.name
      )

    {:ok, socket}
  end

  def handle_event("reset-progress", _, socket) do
    Knowledge.reset_learn_topic_progress(socket.assigns.learning_topic.id, socket.assigns.user.id)

    next_unknown_topic_id =
      Knowledge.get_next_unknown_topic_by_topic(
        socket.assigns.subject.id,
        socket.assigns.learning_topic.id,
        socket.assigns.user.id
      )

    if next_unknown_topic_id != nil do
      next_unknown_topic = Knowledge.get_topic!(next_unknown_topic_id)

      socket =
        assign(socket,
          unknown_topic: next_unknown_topic,
          visited_topics: [next_unknown_topic]
        )

      {:noreply, socket}
    else
      learning_topic = Knowledge.get_topic!(socket.assigns.learning_topic.id)

      {:noreply,
       assign(socket,
         unknown_topic: learning_topic,
         visited_topics: [learning_topic]
       )}
    end
  end

  def handle_event("test", _, socket) do
    # socket = assign(socket, key: value)
    {:noreply, socket}
  end

  def handle_event("understood", _, socket) do
    %{unknown_topic: topic, user: user} = socket.assigns

    attrs = %{topic_id: topic.id, subject_id: topic.subject_id, user_id: user.id, visit_status: :known}

    Knowledge.set_known(attrs)
    learning_topic = socket.assigns.learning_topic
    next_unknown_topic = socket.assigns.unknown_topic

    if next_unknown_topic != learning_topic do
      next_topic_id =
        Knowledge.get_next_unknown_topic_by_topic(
          socket.assigns.subject.id,
          socket.assigns.learning_topic.id,
          socket.assigns.user.id
        )

      unknown_topic =
        if next_topic_id, do: Knowledge.get_topic!(next_topic_id), else: socket.assigns.learning_topic

      visited_topics = socket.assigns.visited_topics
      visited_topics = if unknown_topic, do: visited_topics ++ [unknown_topic], else: visited_topics

      {:noreply, assign(socket, unknown_topic: unknown_topic, visited_topics: visited_topics)}
    else
      {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/#{learning_topic.id}")}
    end
  end

  def handle_event("search", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/search")}
  end

  def render_breadcrumb(assigns) do
    ~H"""
    <div class="h-14">
      <nav class="pt-3 inline-block " aria-label="Breadcrumb">
        <ol class="inline-flex items-center space-x-1 md:space-x-3">
          <li class="inline-flex items-center">
            <a
              href={~p"/subjects"}
              class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-green-600 dark:text-gray-400 dark:hover:text-white"
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
                class="ml-1 text-sm font-medium text-gray-700 hover:text-green-600 md:ml-2 dark:text-gray-400 dark:hover:text-white"
              >
                <%= @subject.name %>
              </a>
            </div>
          </li>
          <li :if={@learning_topic} aria-current="page">
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
                <%= @learning_topic.name %>
              </span>
            </div>
          </li>
        </ol>
      </nav>
      <button
        type="submit"
        phx-click="search"
        class="float-right p-2.5 ml-2 text-sm font-medium text-white bg-green-700 rounded-lg border border-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
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
    </div>
    """
  end

  def render_learn_complete(assigns) do
    ~H"""
    <h1 class="mb-4 text-xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
      Congradulations!
    </h1>
    <h2 class="mb-4 text-lg font-semibold text-gray-900 dark:text-white">
      You should now have a good understanding of the topic <i><b><%= @learning_topic.name %></b></i>.
    </h2>
    <ul class="mb-6 space-y-1 text-gray-800 list-disc list-inside dark:text-gray-400">
      <li>
        Click the <strong>Review</strong> button below if you would like to review this topic again.
      </li>
      <li>
        Click the <strong>Test</strong>
        button if you would like to test your understanding by answering some questions.
      </li>
    </ul>
    <a
      phx-click="reset-progress"
      href="#"
      class="inline-flex items-center justify-center px-5 py-3 text-base font-medium text-center text-white bg-green-700 rounded-lg hover:bg-green-800 focus:ring-4 focus:ring-green-300 dark:focus:ring-green-900"
    >
      Review
    </a>
    <a
      href={~p"/subjects/#{@subject.id}/topics/#{@learning_topic}/test"}
      class="inline-flex items-center justify-center px-5 py-3 text-base font-medium text-center text-white bg-green-700 rounded-lg hover:bg-green-800 focus:ring-4 focus:ring-green-300 dark:focus:ring-green-900"
    >
      Test
    </a>
    """
  end

  def render_buttons(assigns) do
    ~H"""
    <div class="mt-8">
      <button
        phx-click="understood"
        class="mb-5 text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
      >
        Understood
      </button>
    </div>
    """
  end

  def render_topic(assigns) do
    ~H"""
    <div>
      <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-4xl dark:text-white">
        <%= @unknown_topic.name %>
      </h1>
      <div class="border rounded border-grey-900 p-3">
        <p>
          <section class="markdown" id="learn-topic-discription" phx-hook="MountAndUpdate">
            <%= Highlighter.highlight(Earmark.as_html!(@unknown_topic.description)) |> Phoenix.HTML.raw() %>
          </section>
        </p>
      </div>
    </div>
    """
  end

  def render_learning_progress(assigns) do
    ~H"""
    <div class="mb-2">
      <a
        class="text-purple-700"
        href={~p"/subjects/#{@learning_topic.subject_id}/topics/#{@learning_topic.id}"}
        class="text-green-700"
      >
        Learning: <%= @learning_topic.name %>
      </a>
      <div :for={topic <- @visited_topics} :if={@is_admin}>
        <a href={~p"/subjects/#{@subject.id}/topics/#{topic.id}"} class="text-green-700">
          (<%= topic.name %>)
        </a>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <.render_breadcrumb subject={@subject} learning_topic={@learning_topic} />
    <.render_learning_progress
      subject={@subject}
      is_admin={@is_admin}
      learning_topic={@learning_topic}
      visited_topics={@visited_topics}
    />
    <%= if @unknown_topic == nil do %>
      <.render_learn_complete subject={@subject} learning_topic={@learning_topic} />
    <% else %>
      <.render_topic unknown_topic={@unknown_topic} subject={@subject} />
      <.live_component
        module={TopicIssue}
        id={:topic_issue}
        topic_id={@unknown_topic.id}
        subject_id={@subject.id}
        user_id={@user.id}
      />
      <.render_buttons is_admin={@is_admin} />
    <% end %>
    """
  end
end
