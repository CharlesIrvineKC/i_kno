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
    <p class="mb-6 text-lg font-normal text-gray-500 lg:text-xl dark:text-gray-400">
      <strong>IKno</strong>
      is an prototype application for authoring and presenting educational subject matter. It aims to leverage conceptual structures inherent in language to to sequence information to the reader such that learning time is minimized.
    </p>
    <div class="flex flex-wrap">
      <a
        href="#"
        class="mb-5 mr-5 block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
      >
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          Benefit of Registering
        </h5>
        <p class="font-normal text-gray-700 dark:text-gray-400">
          If you register and log in, you can pick any topic that you would like to learn and IKno will present information in an optimal order, taking into account what you have already learned.
        </p>
      </a>
      <a
        href="#"
        class="mb-5 block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
      >
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          Or Register Later
        </h5>
        <p class="font-normal text-gray-700 dark:text-gray-400">
          If you would prefer not to register just yet, you can still explore our subjects. Just press the button below.
        </p>
      </a>
    </div>
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
