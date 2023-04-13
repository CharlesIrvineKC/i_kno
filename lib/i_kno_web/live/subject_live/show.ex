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

  def render(assigns) do
    ~H"""
    
    """
  end
end
