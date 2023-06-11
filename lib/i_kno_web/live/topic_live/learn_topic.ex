defmodule IKnoWeb.TopicLive.LearnTopic do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  alias IKnoWeb.Components.PrereqEditor
  alias IKnoWeb.Components.TopicIssue
  alias IKnoWeb.Highlighter

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  def mount(%{"subject_id" => subject_id, "topic_id" => topic_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    learning_topic = Knowledge.get_topic!(String.to_integer(topic_id))
    subject = Knowledge.get_subject!(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    is_admin = Accounts.is_admin(subject_id, user.id)
    topic_ids = Knowledge.get_next_unknown_topic_topics(subject_id, learning_topic.id, user.id)

    topic =
      if topic_ids != [] do
        Knowledge.get_topic!(hd(topic_ids))
      else
        Knowledge.get_topic!(learning_topic.id)
      end

    prereqs = if topic, do: Knowledge.get_topic_prereqs(topic.id), else: []
    is_known = if topic, do: Knowledge.get_known(topic.id, user.id), else: nil

    socket =
      assign(
        socket,
        subject: subject,
        user: user,
        is_admin: is_admin,
        learning_topic: learning_topic,
        topic: topic,
        visited_topics: [topic],
        next_topic_ids: if(length(topic_ids) > 0, do: tl(topic_ids), else: []),
        is_known: is_known,
        prereqs: prereqs,
        mode: :learn_topic,
        page_title: "Learn: " <> topic.name,
        learn_topic_complete: length(topic_ids) == 0
      )

    {:ok, socket}
  end

  def handle_event("reset-progress", _, socket) do
    Knowledge.reset_learn_topic_progress(socket.assigns.learning_topic.id, socket.assigns.user.id)

    topic_ids =
      Knowledge.get_next_unknown_topic_topics(
        socket.assigns.subject.id,
        socket.assigns.learning_topic.id,
        socket.assigns.user.id
      )

    if topic_ids != [] do
      topic = Knowledge.get_topic!(hd(topic_ids))
      next_topic_ids = tl(topic_ids)
      prereqs = Knowledge.get_topic_prereqs(topic.id)

      socket =
        assign(socket,
          topic: topic,
          visited_topics: [topic],
          next_topic_ids: next_topic_ids,
          prereqs: prereqs,
          learn_topic_complete: false
        )

      {:noreply, socket}
    else
      topic = Knowledge.get_topic!(socket.assigns.learning_topic.id)
      next_topic_ids = []
      prereqs = Knowledge.get_topic_prereqs(topic.id)

      {:noreply,
       assign(socket,
         topic: topic,
         visited_topics: [topic],
         prereqs: prereqs,
         next_topic_ids: next_topic_ids,
         learn_topic_complete: true
       )}
    end
  end

  def handle_event("understood", _, socket) do
    Knowledge.set_known(socket.assigns.topic.id, socket.assigns.user.id)
    visited_topics = socket.assigns.visited_topics

    if !socket.assigns.learn_topic_complete do
      next_topic_ids = get_next_topics(socket)
      next_topic_id = List.first(next_topic_ids)

      if next_topic_id do
        topic = Knowledge.get_topic!(next_topic_id)

        next_topic_ids = tl(next_topic_ids)
        prereqs = Knowledge.get_topic_prereqs(topic.id)

        {:noreply,
         assign(socket,
           topic: topic,
           visited_topics: visited_topics ++ [topic],
           prereqs: prereqs,
           next_topic_ids: next_topic_ids
         )}
      else
        topic = Knowledge.get_topic!(socket.assigns.learning_topic.id)
        next_topic_ids = []
        prereqs = Knowledge.get_topic_prereqs(topic.id)

        {:noreply,
         assign(socket,
           topic: topic,
           visited_topics: visited_topics ++ [topic],
           prereqs: prereqs,
           next_topic_ids: next_topic_ids,
           learn_topic_complete: true
         )}
      end
    else
      {:noreply, assign(socket, topic: nil, prereqs: [], next_topic_ids: [])}
    end
  end

  def handle_event("search", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/search")}
  end

  defp get_next_topics(socket) do
    if length(socket.assigns.next_topic_ids) > 0 do
      socket.assigns.next_topic_ids
    else
      Knowledge.get_next_unknown_topic_topics(
        socket.assigns.subject.id,
        socket.assigns.learning_topic.id,
        socket.assigns.user.id
      )
    end
  end

  def render_breadcrumb(assigns) do
    ~H"""
    <div class="h-14">
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
    </div>
    """
  end

  def render_learn_complete(assigns) do
    ~H"""
    <h1 class="mb-4 text-xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
      Congradulations!
    </h1>
    <p class="mb-6 text-lg font-normal text-gray-500 lg:text-xl sm:px-16 xl:px-48 dark:text-gray-400">
      You should now have a good understanding of the topic <i><b><%= @learning_topic.name %></b></i>. Click the <strong>Review</strong> button below if you would like to review this topic again.
    </p>
    <a
      phx-click="reset-progress"
      href="#"
      class="inline-flex items-center justify-center px-5 py-3 text-base font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-900"
    >
      Review
    </a>
    """
  end

  def render_buttons(assigns) do
    ~H"""
    <div class="mt-8">
      <button
        :if={!@is_known}
        phx-click="understood"
        class="mb-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
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
        <%= @topic.name %>
      </h1>
      <div class="border rounded border-grey-900 p-3">
        <p>
          <section class="markdown" phx-update="ignore" id="topic-description" >
            <%= Highlighter.highlight(Earmark.as_html!(@topic.description)) |> Phoenix.HTML.raw() %>
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
    <.render_breadcrumb subject={@subject} topic={@topic} />
    <.render_learning_progress
      subject={@subject}
      is_admin={@is_admin}
      learning_topic={@learning_topic}
      visited_topics={@visited_topics}
    />
    <%= if @topic == nil do %>
      <.render_learn_complete subject={@subject} learning_topic={@learning_topic} />
    <% else %>
      <.render_topic topic={@topic} subject={@subject} />
      <.live_component
        module={TopicIssue}
        id={:topic_issue}
        topic_id={@topic.id}
        subject_id={@subject.id}
        user_id={@user.id}
      />
      <.render_buttons is_known={@is_known} is_admin={@is_admin} />
      <%= if @is_admin do %>
        <.live_component module={PrereqEditor} id={:prereq_editor} topic={@topic} subject={@subject} />
      <% end %>
    <% end %>
    """
  end
end
