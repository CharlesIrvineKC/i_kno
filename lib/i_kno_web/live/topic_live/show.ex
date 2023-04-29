defmodule IKnoWeb.TopicLive.Show do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts
  alias IKnoWeb.Components.PrereqEditor

  def mount(%{"subject_id" => subject_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    subject = Knowledge.get_subject!(subject_id)
    user = Accounts.get_user_by_session_token(user_token)

    socket = assign(socket, subject: subject, user: user)

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :learn_topic, %{"topic_id" => topic_id}) do
    subject_id = socket.assigns.subject.id
    learning_topic_id = String.to_integer(topic_id)
    user = socket.assigns.user
    topic_ids = Knowledge.get_next_unknown_topic_topics(subject_id, learning_topic_id, user.id)
    topic = if topic_ids != [], do: Knowledge.get_topic!(hd(topic_ids)), else: nil
    prereqs = if topic, do: Knowledge.get_prereqs(topic.id), else: []
    is_known = if topic, do: Knowledge.get_known(topic.id, user.id), else: nil

    assign(
      socket,
      learning_topic_id: learning_topic_id,
      topic: topic,
      next_topic_ids: if(length(topic_ids) > 0, do: tl(topic_ids), else: []),
      is_known: is_known,
      prereqs: prereqs,
      mode: :learn_topic,
      learn_topic_complete: false
    )
  end

  defp apply_action(socket, :learn_subject, _params) do
    subject_id = socket.assigns.subject.id
    user = socket.assigns.user
    topic_ids = Knowledge.get_next_unknown_subject_topics(subject_id, user.id)
    topic = if topic_ids != [], do: Knowledge.get_topic!(hd(topic_ids)), else: nil
    prereqs = if topic, do: Knowledge.get_prereqs(topic.id), else: []
    is_known = if topic, do: Knowledge.get_known(topic.id, user.id), else: nil

    assign(
      socket,
      topic: topic,
      next_topic_ids: if(length(topic_ids) > 0, do: tl(topic_ids), else: nil),
      is_known: is_known,
      prereqs: prereqs,
      mode: :learn_subject
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
      mode: :show
    )
  end

  def handle_event("new", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/new")}
  end

  def handle_event("review", _, socket) do
    case socket.assigns.mode do
      :learn_subject ->
        Knowledge.reset_learn_subject_progress(socket.assigns.subject.id, socket.assigns.user.id)

        topic_ids =
          Knowledge.get_next_unknown_subject_topics(socket.assigns.subject.id, socket.assigns.user.id)

        topic = Knowledge.get_topic!(hd(topic_ids))
        next_topic_ids = tl(topic_ids)
        prereqs = Knowledge.get_prereqs(topic.id)
        socket = assign(socket, topic: topic, next_topic_ids: next_topic_ids, prereqs: prereqs)
        {:noreply, socket}

      :learn_topic ->
        Knowledge.reset_learn_topic_progress(socket.assigns.learning_topic_id, socket.assigns.user.id)

        topic_ids =
          Knowledge.get_next_unknown_topic_topics(
            socket.assigns.subject.id,
            socket.assigns.learning_topic_id,
            socket.assigns.user.id
          )

        if topic_ids != [] do
          topic = Knowledge.get_topic!(hd(topic_ids))
          next_topic_ids = tl(topic_ids)
          prereqs = Knowledge.get_prereqs(topic.id)

          socket =
            assign(socket,
              topic: topic,
              next_topic_ids: next_topic_ids,
              prereqs: prereqs,
              learn_topic_complete: false
            )

          {:noreply, socket}
        else
          topic = Knowledge.get_topic!(socket.assigns.learning_topic_id)
          next_topic_ids = []
          prereqs = Knowledge.get_prereqs(topic.id)

          {:noreply,
           assign(socket,
             topic: topic,
             prereqs: prereqs,
             next_topic_ids: next_topic_ids,
             learn_topic_complete: true
           )}
        end
    end
  end

  def handle_event("understood", _, socket) do
    Knowledge.set_known(socket.assigns.topic.id, socket.assigns.user.id)

    case socket.assigns.mode do
      :show ->
        {:noreply, socket}

      :learn_subject ->
        next_topic_ids = get_next_topics(socket)
        next_topic_id = List.first(next_topic_ids)

        if next_topic_id do
          topic = Knowledge.get_topic!(next_topic_id)
          next_topic_ids = tl(next_topic_ids)
          prereqs = Knowledge.get_prereqs(topic.id)
          {:noreply, assign(socket, topic: topic, prereqs: prereqs, next_topic_ids: next_topic_ids)}
        else
          topic = nil
          next_topic_ids = []
          prereqs = []
          {:noreply, assign(socket, topic: topic, prereqs: prereqs, next_topic_ids: next_topic_ids)}
        end

      :learn_topic ->
        if !socket.assigns.learn_topic_complete do
          next_topic_ids = get_next_topics(socket)
          next_topic_id = List.first(next_topic_ids)

          if next_topic_id do
            topic = Knowledge.get_topic!(next_topic_id)
            next_topic_ids = tl(next_topic_ids)
            prereqs = Knowledge.get_prereqs(topic.id)
            {:noreply, assign(socket, topic: topic, prereqs: prereqs, next_topic_ids: next_topic_ids)}
          else
            topic = Knowledge.get_topic!(socket.assigns.learning_topic_id)
            next_topic_ids = []
            prereqs = Knowledge.get_prereqs(topic.id)

            {:noreply,
             assign(socket,
               topic: topic,
               prereqs: prereqs,
               next_topic_ids: next_topic_ids,
               learn_topic_complete: true
             )}
          end
        else
          {:noreply, assign(socket, topic: nil, prereqs: [], next_topic_ids: [])}
        end
    end
  end

  def handle_event("edit", _, socket) do
    topic = socket.assigns.topic
    {:noreply, redirect(socket, to: ~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/edit")}
  end

  def handle_event("learn", _, socket) do
    # Knowledge.set_learning(socket.assigns.topic.id, socket.assigns.user.id)
    topic = socket.assigns.topic
    {:noreply, redirect(socket, to: ~p"/subjects/#{topic.subject_id}/topics/#{topic.id}/learn")}
  end

  defp get_next_topics(socket) do
    case socket.assigns.mode do
      :show ->
        nil

      :learn_subject ->
        if length(socket.assigns.next_topic_ids) > 0 do
          socket.assigns.next_topic_ids
        else
          Knowledge.get_next_unknown_subject_topics(socket.assigns.subject.id, socket.assigns.user.id)
        end

      :learn_topic ->
        if length(socket.assigns.next_topic_ids) > 0 do
          socket.assigns.next_topic_ids
        else
          Knowledge.get_next_unknown_topic_topics(
            socket.assigns.subject.id,
            socket.assigns.learning_topic_id,
            socket.assigns.user.id
          )
        end
    end
  end

  def render(assigns) do
    ~H"""
    <nav class="mb-10 flex" aria-label="Breadcrumb">
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
        <div class="mt-12">
          <button
            :if={!@is_known}
            phx-click="understood"
            class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            Understood
          </button>
          <button
            :if={!@is_known}
            phx-click="learn"
            class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            Learn
          </button>
          <button
            phx-click="edit"
            class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            Edit
          </button>
          <button
            phx-click="new"
            class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            New
          </button>
        </div>
      </div>
      <.live_component module={PrereqEditor} id={:prereq_editor} topic={@topic} subject={@subject} />
    <% end %>
    """
  end
end
