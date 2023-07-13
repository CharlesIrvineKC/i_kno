defmodule IKnoWeb.TopicLive.ShowTopic do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  alias IKnoWeb.Components.PrereqEditor
  alias IKnoWeb.Components.QuestionEditor
  alias IKnoWeb.Components.TopicIssue
  alias IKnoWeb.Highlighter

  def mount(%{"subject_id" => subject_id, "topic_id" => topic_id}, session, socket) do
    topic = Knowledge.get_topic!(String.to_integer(topic_id))
    subject_id = String.to_integer(subject_id)

    user_token = Map.get(session, "user_token")

    {user_id, is_admin, is_known} =
      if user_token do
        user = Accounts.get_user_by_session_token(user_token)
        user_id = user.id
        is_admin = Accounts.is_admin(subject_id, user.id)
        is_known = Knowledge.get_known(topic.id, user.id)
        {user_id, is_admin, is_known}
      else
        {nil, false, false}
      end

    subject = Knowledge.get_subject!(subject_id)
    prereqs = Knowledge.get_topic_prereqs(topic.id)

    socket =
      assign(
        socket,
        subject: subject,
        user_id: user_id,
        is_admin: is_admin,
        topic: topic,
        is_known: is_known,
        prereqs: prereqs,
        mode: :show,
        page_title: topic.name
      )

    {:ok, socket}
  end

  def handle_event("understood", _, socket) do
    Knowledge.set_known(socket.assigns.topic.id, socket.assigns.user_id)
    {:noreply, assign(socket, is_known: true)}
  end

  def handle_event("search", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}/topics/search")}
  end

  def handle_event("delete", _, socket) do
    Knowledge.delete_topic(socket.assigns.topic)
    {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.topic.subject_id}/topics")}
  end

  def handle_event("review-topic", _, socket) do
    topic = socket.assigns.topic
    subject = socket.assigns.subject
    Knowledge.reset_learn_topic_progress(topic.id, socket.assigns.user_id)
    {:noreply, redirect(socket, to: ~p"/subjects/#{subject.id}/topics/#{topic.id}/learn")}
  end

  def toggle_show_topic(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#topic-description")
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
    <h1 class="mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
      Congradulations!
    </h1>
    <p class="mb-6 text-lg font-normal text-gray-500 lg:text-xl sm:px-16 xl:px-48 dark:text-gray-400">
      You have completed your review of <i><b><%= @subject.name %></b></i>. Click the button below if you would like to review this subject again.
    </p>
    <a
      phx-click="reset-subject"
      href="#"
      class="inline-flex items-center justify-center px-5 py-3 text-base font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-900"
    >
      Review
    </a>
    """
  end

  def render_buttons(assigns) do
    ~H"""
    <div class="mt-8 [&>button]:mb-1">
      <button
        :if={!@is_known}
        data-popover-target="popover-learn"
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        <a href={"/subjects/#{@topic.subject_id}/topics/#{@topic.id}/learn"}>Learn</a>
      </button>
      <div
        data-popover
        id="popover-learn"
        role="tooltip"
        class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity transition-opacity duration-5000 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
      >
        <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
          <h3 class="font-semibold text-gray-900 dark:text-white">Learn Subject</h3>
        </div>
        <div class="px-3 py-2">
          <p>
            Review all of this topic's prerequisite material.
          </p>
        </div>
        <div data-popper-arrow></div>
      </div>
      <button
        :if={@is_known}
        phx-click="review-topic"
        data-popover-target="popover-learn"
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        Review
      </button>
      <div
        data-popover
        id="popover-learn"
        role="tooltip"
        class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity transition-opacity duration-5000 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
      >
        <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
          <h3 class="font-semibold text-gray-900 dark:text-white">Learn Subject</h3>
        </div>
        <div class="px-3 py-2">
          <p>
            Let IKno present prereqisite topics for <strong><%= @topic.name %></strong>
            based on what you already know. <strong>Requires login.</strong>
          </p>
        </div>
        <div data-popper-arrow></div>
      </div>
      <button
        :if={@is_admin}
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        <a href={"/subjects/#{@topic.subject_id}/topics/#{@topic.id}/edit"}>Edit</a>
      </button>
      <.render_delete_button is_admin={@is_admin} />
      <button
        :if={@is_admin}
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        <a href={"/subjects/#{@topic.subject_id}/topics/new"}>New</a>
      </button>
    </div>
    """
  end

  def render_delete_button(assigns) do
    ~H"""
    <button
      :if={@is_admin}
      data-modal-target="popup-modal"
      data-modal-toggle="popup-modal"
      class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
    >
      Delete
    </button>

    <div
      id="popup-modal"
      tabindex="-1"
      class="fixed top-0 left-0 right-0 z-50 hidden p-4 overflow-x-hidden overflow-y-auto md:inset-0 h-[calc(100%-1rem)] max-h-full"
    >
      <div class="relative w-full max-w-md max-h-full">
        <div class="relative bg-white rounded-lg shadow dark:bg-gray-700">
          <button
            type="button"
            class="absolute top-3 right-2.5 text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center dark:hover:bg-gray-800 dark:hover:text-white"
            data-modal-hide="popup-modal"
          >
            <svg
              aria-hidden="true"
              class="w-5 h-5"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
            <span class="sr-only">Close modal</span>
          </button>
          <div class="p-6 text-center">
            <svg
              aria-hidden="true"
              class="mx-auto mb-4 text-gray-400 w-14 h-14 dark:text-gray-200"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              >
              </path>
            </svg>
            <h3 class="mb-5 text-lg font-normal text-gray-500 dark:text-gray-400">
              Are you sure you want to delete this topic?
            </h3>
            <button
              data-modal-hide="popup-modal"
              phx-click="delete"
              type="button"
              class="text-white bg-red-600 hover:bg-red-800 focus:ring-4 focus:outline-none focus:ring-red-300 dark:focus:ring-red-800 font-medium rounded-lg text-sm inline-flex items-center px-5 py-2.5 text-center mr-2"
            >
              Yes, I'm sure
            </button>
            <button
              data-modal-hide="popup-modal"
              type="button"
              class="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-gray-200 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10 dark:bg-gray-700 dark:text-gray-300 dark:border-gray-500 dark:hover:text-white dark:hover:bg-gray-600 dark:focus:ring-gray-600"
            >
              No, cancel
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def render_topic(assigns) do
    ~H"""
    <div>
      <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-4xl dark:text-white">
        <%= @topic.name %>
      </h1>
      <div :if={@is_admin} class="flex items-center mb-4">
        <input
          phx-click={toggle_show_topic()}
          id="default-checkbox"
          type="checkbox"
          value=""
          class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
        />
        <label for="default-checkbox" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
          Show/Hide
        </label>
      </div>
      <div id="topic-description" class="border rounded border-grey-900 p-3">
        <p>
          <section class="markdown" id="topic-discription" phx-hook="Mount">
            <%= Highlighter.highlight(Earmark.as_html!(@topic.description)) |> Phoenix.HTML.raw() %>
          </section>
        </p>
      </div>
    </div>
    """
  end

  def render_admin_panels(assigns) do
    ~H"""
    <div class="mt-5" id="accordion-collapse" data-accordion="open">
      <h2 id="preq-heading">
        <button
          type="button"
          class="flex items-center justify-between w-full p-5 font-medium text-left text-gray-500 border border-b-0 border-gray-200 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800"
          data-accordion-target="#prereq-body"
          aria-expanded="false"
          aria-controls="prereq-body"
        >
          <span>Prerequisites</span>
          <svg
            data-accordion-icon
            class="w-3 h-3 rotate-180 shrink-0"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 10 6"
          >
            <path
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 5 5 1 1 5"
            />
          </svg>
        </button>
      </h2>
      <div id="prereq-body" class="hidden" aria-labelledby="preq-heading">
        <div class="p-5 border border-b-0 border-gray-200 dark:border-gray-700 dark:bg-gray-900">
          <.live_component module={PrereqEditor} id={:prereq_editor} topic={@topic} subject={@subject} />
        </div>
      </div>
      <h2 id="questions-heading">
        <button
          type="button"
          class="flex items-center justify-between w-full p-5 font-medium text-left text-gray-500 border border-gray-200 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800"
          data-accordion-target="#questions-body"
          aria-expanded="false"
          aria-controls="questions-body"
        >
          <span>Questions</span>
          <svg
            data-accordion-icon
            class="w-3 h-3 rotate-180 shrink-0"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 10 6"
          >
            <path
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 5 5 1 1 5"
            />
          </svg>
        </button>
      </h2>
      <div id="questions-body" class="hidden" aria-labelledby="questions-heading">
        <div class="p-5 border border-t-0 border-gray-200 dark:border-gray-700">
          <.live_component module={QuestionEditor} id={:question_editor} topic={@topic} subject={@subject} />
        </div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <.render_breadcrumb subject={@subject} topic={@topic} />
    <%= if @topic == nil do %>
      <.render_learn_complete subject={@subject} />
    <% else %>
      <.render_topic topic={@topic} subject={@subject} is_admin={@is_admin}/>
      <%= if @user_id do %>
        <.live_component
          module={TopicIssue}
          id={:topic_issue}
          topic_id={@topic.id}
          subject_id={@subject.id}
          user_id={@user_id}
        />
      <% end %>
      <.render_buttons is_known={@is_known} is_admin={@is_admin} user_id={@user_id} topic={@topic} />
      <%= if @is_admin do %>
        <.render_admin_panels topic={@topic} subject={@subject} />
      <% end %>
    <% end %>
    """
  end
end
