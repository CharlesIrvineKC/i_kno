defmodule IKnoWeb.SubjectLive.Edit do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  def mount(%{"id" => id}, _session, socket) do
    {:ok, assign(socket, subject: Knowledge.get_subject!(id))}
  end

  def render(assigns) do
    ~H"""
    <div class="px-12">
      <label for="message" class="block mb-4 text-lg font-medium text-gray-900 dark:text-white">
        <%= @subject.name %>
      </label>
      <div>
        <article>
          <%= Earmark.as_html!(@subject.description, escape: false, inner_html: true, compact_output: true)
          |> Phoenix.HTML.raw() %>
        </article>
      </div>
      <button
        type="button"
        phx-click="edit"
        class="mt-6 focus:outline-none text-white bg-green-700 hover:bg-green-800 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 "
      >
        Save
      </button>
      <button
        type="button"
        phx-click="edit"
        class="mt-6 focus:outline-none text-white bg-orange-700 hover:bg-orange-800 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-orange-600 dark:hover:bg-orange-700 "
      >
        Cancel
      </button>
    </div>
    """
  end
end
