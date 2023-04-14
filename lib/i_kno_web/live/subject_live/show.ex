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
      <%= Earmark.as_html!(@subject.description,
        escape: false,
        inner_html: true,
        compact_output: true
      )
      |> Phoenix.HTML.raw() %>
    </p>
    """
  end
end
