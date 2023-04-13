defmodule IKnoWeb.SubjectLive.Show do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  def mount(%{"id" => id}, _session, socket) do
    socket =
      assign(socket,
        subject: Knowledge.get_subject!(id),
        mode: :view
      )

    {:ok, socket}
  end

  def handle_event("edit", _, socket) do
    socket = assign(socket, mode: :edit)
    {:noreply, socket}
  end

  def handle_event("cancel", _, socket) do
    socket = assign(socket, mode: :view)
    {:noreply, socket}
  end

  def handle_event("save", %{"description" => description}, socket) do

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <form phx-submit="save">
      <div class="px-12">
        <label for="message" class="block mb-4 text-lg font-medium text-gray-900 dark:text-white">
          <%= @subject.name %>
        </label>
        <%= if @mode == :view do %>
          <div>
            <article>
              <%= Earmark.as_html!(@subject.description, escape: false, inner_html: true, compact_output: true)
              |> Phoenix.HTML.raw() %>
            </article>
          </div>
          <button
            type="button"
            phx-click="edit"
            class="mt-6 focus:outline-none text-white bg-red-700 hover:bg-red-800 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 "
          >
            Edit
          </button>
        <% else %>
          <div>
            <textarea
              id="description"
              name="description"
              rows="20"
              class="block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
              placeholder="Write your thoughts here..."
            >
          <%= @subject.description %>
          </textarea>
          </div>
          <button
            type="submit"
            class="mt-6 focus:outline-none text-white bg-red-700 hover:bg-red-800 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 "
          >
            Save
          </button>
          <button
            type="button"
            phx-click="cancel"
            class="mt-6 focus:outline-none text-white bg-red-700 hover:bg-red-800 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 "
          >
            Cancel
          </button>
        <% end %>
      </div>
    </form>
    """
  end
end
