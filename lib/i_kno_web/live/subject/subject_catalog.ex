defmodule IKnoWeb.SubjectLive.Catalog do
  use IKnoWeb, :live_view

  def mount(_parameters, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div>
        Hello
      </div>
    """
  end
end
