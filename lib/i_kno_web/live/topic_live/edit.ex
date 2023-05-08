defmodule IKnoWeb.TopicLive.Edit do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Knowledge.Topic

  on_mount {IKnoWeb.UserAuth, :ensure_authenticated}

  def mount(%{"subject_id" => subject_id}, _session, socket) do
    subject = Knowledge.get_subject!(subject_id)
    socket = assign(socket, subject: subject)
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    assign(socket, topic: %Topic{}, mode: :new)
  end

  def apply_action(socket, :edit, %{"topic_id" => topic_id}) do
    topic = Knowledge.get_topic!(String.to_integer(topic_id))
    assign(socket, topic: topic, mode: :edit)
  end

  defp handle_is_task(%{"is_task" => "on"} = params), do: %{params | "is_task" => true}
  defp handle_is_task(params), do: Map.put(params, "is_task", false)

  def handle_event("save", topic_params, socket) do
    topic_params = handle_is_task(topic_params)

    if socket.assigns.mode == :edit do
      {:ok, topic} = Knowledge.update_topic(socket.assigns.topic, topic_params)
      socket = assign(socket, topic: topic)
      subject_id = socket.assigns.subject.id
      {:noreply, redirect(socket, to: ~p"/subjects/#{subject_id}/topics/#{topic.id}")}
    else
      subject = socket.assigns.subject
      topic_params = Map.put(topic_params, "subject_id", subject.id)
      {:ok, topic} = Knowledge.create_topic(topic_params)
      {:noreply, redirect(socket, to: ~p"/subjects/#{subject.id}/topics/#{topic.id}")}
    end
  end

  def handle_event("cancel", _, socket) do
    if socket.assigns.mode == :edit do
      subject_id = socket.assigns.subject.id
      topic_id = socket.assigns.topic.id
      {:noreply, redirect(socket, to: ~p"/subjects/#{subject_id}/topics/#{topic_id}")}
    else
      {:noreply, redirect(socket, to: ~p"/subjects/#{socket.assigns.subject.id}")}
    end
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-2xl font-extrabold leading-none tracking-tight text-gray-900 md:text-3xl lg:text-3xl dark:text-white">
      <%= @subject.name %>
    </h1>
    <div>
      <form phx-submit="save">
        <div class="mb-6">
          <label for="name" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            Name
          </label>
          <input
            type="text"
            id="name"
            name="name"
            value={@topic.name}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          />
        </div>
        <div class="mb-6">
          <label for="description" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            Description
          </label>
          <textarea
            id="description"
            name="description"
            rows="25"
            class="w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"><%= @topic.description %></textarea>
          <label class="relative inline-flex items-center cursor-pointer">
            <%= if @topic.is_task do %>
              <input checked type="checkbox" id="is_task" name="is_task" class="sr-only peer" />
            <% else %>
              <input type="checkbox" id="is_task" name="is_task" class="sr-only peer" />
            <% end %>
            <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4    peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600">
            </div>
            <span class="ml-3 text-sm font-medium text-gray-900 dark:text-gray-300">Task?</span>
          </label>
        </div>
        <button
          type="submit"
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Save
        </button>
        <button
          phx-click="cancel"
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Cancel
        </button>
        <button
          phx-click="preview"
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Preview
        </button>
      </form>
    </div>
    """
  end
end
