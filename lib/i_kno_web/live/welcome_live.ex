defmodule IKnoWeb.WelcomeLive do
  use IKnoWeb, :live_view

  def mount(_parameters, _session, socket) do
    {:ok, assign(socket, page_title: "Welcome to IKno")}
  end

  def handle_event("list-subjects", _, socket) do
    {:noreply, redirect(socket, to: ~p"/subjects")}
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
      Welcome to IKno
    </h1>
    <p class="mb-3 text-gray-900 dark:text-gray-400">
      <strong>IKno</strong>
      is an experimental application for authoring and presenting educational subject matter.
    </p>
    <p class="mb-3 text-gray-900 dark:text-gray-400">
      If you register and log in, you can pick any topic that you would like to learn and IKno will present information in an optimal order, taking into account what you have already learned.
    </p>
    <p class="mb-3 text-gray-900 dark:text-gray-400">
      If you would prefer not to register just yet, you can still explore our subjects. Just press the button below.
    </p>
    <button
      phx-click="list-subjects"
      type="button"
      class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
    >
      List of Subjects
    </button>
    """
  end
end
