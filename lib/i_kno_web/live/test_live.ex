defmodule IKnoWeb.TestLive do
  use IKnoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, status: :open)}
  end

  def handle_event("event", %{"status" => status}, socket) do
    socket = assign(socket, status: String.to_atom(status))
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="flex items-center mr-4">
        <input
          checked
          phx-click="event"
          phx-value-status="open"
          id="inline-radio"
          type="radio"
          value=""
          name="inline-radio-group"
          class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
        />
        <label for="inline-radio" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
          Inline 1
        </label>
      </div>
      <div class="flex items-center mr-4">
        <input
          phx-click="event"
          phx-value-status="closed"
          id="inline-2-radio"
          type="radio"
          value=""
          name="inline-radio-group"
          class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
        />
        <label for="inline-2-radio" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">
          Inline 2
        </label>
      </div>
    </div>
    """
  end
end
