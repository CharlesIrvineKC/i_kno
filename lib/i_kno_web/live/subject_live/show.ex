defmodule IKnoWeb.SubjectLive.Show do
  use IKnoWeb, :live_view

  alias IKno.Knowledge

  def mount(%{"subject_id" => subject_id}, _session, socket) do
    socket =
      assign(socket,
        subject: Knowledge.get_subject!(subject_id)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
      <%= @subject.name %>
    </h1>
    <p class="mb-3 text-black dark:text-gray-400">
      <%= @subject.summary %>
    </p>
    <p class="text-black dark:text-gray-400">
      <section class="markdown">
        <%= Earmark.as_html!(@subject.description) |> Phoenix.HTML.raw() %>
      </section>
    </p>
    <button
      type="button"
      class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/#{@subject.id}/topics/learn"}>Learn</a>
    </button>
    <button
      type="button"
      class="mt-12 focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800"
    >
      <a href={~p"/subjects/#{@subject.id}/edit"}>Edit</a>
    </button>
    """
  end
end
