defmodule IKnoWeb.SubjectLive.Show do
  use IKnoWeb, :live_view
  alias IKno.Knowledge

  def mount(%{"id" => id}, _session, socket) do
    {:ok, assign(socket, subject: Knowledge.get_subject!(id))}
  end

  def render(assigns) do
    ~H"""
    <label for="message" class="block mb-2 text-lg font-medium text-gray-900 dark:text-white">
      <%= @subject.name %>
    </label>
    <div>
      <article>
        <%=
          Earmark.as_html!(@subject.description, escape: false, inner_html: true, compact_output: true)
          |> Phoenix.HTML.raw()
        %>
      </article>
    </div>
    """
  end
end
