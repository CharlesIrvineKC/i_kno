defmodule IKnoWeb.WelcomeLive do
  use IKnoWeb, :live_view

  def mount(_parameters, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="bg-white dark:bg-gray-900">
      <div class="py-8 px-4 mx-auto max-w-screen-xl text-center lg:py-16">
        <h1 class="mb-4 text-4xl font-extrabold tracking-tight leading-none text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
          An open door to knowledge
        </h1>
        <p class="mb-8 text-lg font-normal text-gray-500 lg:text-xl sm:px-16 lg:px-48 dark:text-gray-400">
          Welcome to <strong>IKno</strong>, an experimental application for authoring and presenting educational subject matter. One of the subjects is <strong>Phoenix LiveView</strong>, a framework for authoring web applications.
        </p>
        <p class="mb-8 text-sm font-normal text-gray-500 sm:px-16 lg:px-48 dark:text-gray-400">
          <strong>Hint:</strong> Hover over buttons and links to understand how things works.
        </p>
        <div class="flex flex-col space-y-4 sm:flex-row sm:justify-center sm:space-y-0 sm:space-x-4">
          <a
            data-popover-target="popover-default"
            href={~p"/subjects"}
            class="inline-flex justify-center items-center py-3 px-5 text-base font-medium text-center text-white rounded-lg bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-900"
          >
            Enter
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-6 h-6">
              <path
                fill-rule="evenodd"
                d="M7.5 3.75A1.5 1.5 0 006 5.25v13.5a1.5 1.5 0 001.5 1.5h6a1.5 1.5 0 001.5-1.5V15a.75.75 0 011.5 0v3.75a3 3 0 01-3 3h-6a3 3 0 01-3-3V5.25a3 3 0 013-3h6a3 3 0 013 3V9A.75.75 0 0115 9V5.25a1.5 1.5 0 00-1.5-1.5h-6zm10.72 4.72a.75.75 0 011.06 0l3 3a.75.75 0 010 1.06l-3 3a.75.75 0 11-1.06-1.06l1.72-1.72H9a.75.75 0 010-1.5h10.94l-1.72-1.72a.75.75 0 010-1.06z"
                clip-rule="evenodd"
              />
            </svg>
          </a>
          <div
            data-popover
            id="popover-default"
            role="tooltip"
            class="absolute z-10 invisible inline-block w-64 text-sm text-gray-500 transition-opacity duration-300 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"
          >
            <div class="px-3 py-2 bg-gray-100 border-b border-gray-200 rounded-t-lg dark:border-gray-600 dark:bg-gray-700">
              <h3 class="font-semibold text-gray-900 dark:text-white">Subjects</h3>
            </div>
            <div class="px-3 py-2">
              <p>Show all available IKno subjects.</p>
            </div>
            <div data-popper-arrow></div>
          </div>
        </div>
      </div>
    </section>
    """
  end
end
