defmodule IKnoWeb.TestLive do
  use IKnoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

    """
  end
end
