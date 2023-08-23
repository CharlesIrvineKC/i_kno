defmodule IKnoWeb.WelcomeLive do
  use IKnoWeb, :live_view

  alias IKno.Accounts

  def mount(_parameters, session, socket) do
    user_token = Map.get(session, "user_token")
    user = if user_token, do: Accounts.get_user_by_session_token(user_token)
    {:ok, assign(socket, page_title: "Welcome to IKno", user: user)}
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
      <b>IKno</b>
      is an prototype application for authoring and presenting educational subject matter. It aims to leverage conceptual structures inherent in language to to sequence information to the reader such that learning time is minimized.
    </p>
    <div class="flex flex-wrap">
      <a
        :if={!@user}
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
        :if={!@user}
        href="#"
        class="mb-5 mr-5 block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
      >
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          Or Register Later
        </h5>
        <p class="font-normal text-gray-700 dark:text-gray-400">
          If you would prefer not to register just yet, you can still explore our subjects. Just press the button below.
        </p>
      </a>
      <a
        href="#"
        class="mb-5 mr-5 block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
      >
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          Subjects and Topics
        </h5>
        <p class="font-normal text-gray-700 dark:text-gray-400">
          Information in IKno is organized into <b>subjects</b> and <b>topics</b>. A <b>subject</b> is composed of a set of <b>topics</b>.
        </p>
        <p class="mt-3 font-normal text-gray-700 dark:text-gray-400">
          IKno knows how topics depend on each other, allowing topics to presented in a sequence that
          optimizes learning effectiveness.
        </p>
      </a>
      <a
        href="#"
        class="mb-5 mr-5 block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
      >
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          Learning Mode
        </h5>
        <p class="font-normal text-gray-700 dark:text-gray-400">
          <b>Learning mode</b> refers to having IKno step you through topics based on what you already know. Topics are ordered from the most fundamental to the most complex.
        </p>
        <p class="mt-3 font-normal text-gray-700 dark:text-gray-400">
          There are two ways to use learning mode: at the <b>subject level</b> or at the <b>topic level</b>.
        </p>
        <p class="mt-3 font-normal text-gray-700 dark:text-gray-400">
          At the <b>subject</b> level, IKno will present topics from the subject as a whole.
        </p>
        <p class="mt-3 font-normal text-gray-700 dark:text-gray-400">
          At the <b>topic</b> level, IKno will present only those topics required for the understanding of the selected topic.
        </p>
      </a>
      <a
        href="#"
        class="mb-5 mr-5 block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
      >
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          Testing Mode
        </h5>
        <p class="font-normal text-gray-700 dark:text-gray-400">
          In <b>Testing mode</b>, IKno will present questions on the topics that you have learned.
        </p>
        <p class="mt-3 font-normal text-gray-700 dark:text-gray-400">
          Again, there are two ways to use testing mode: at the <b>subject level</b> or at the <b>topic level</b>.
        </p>
        <p class="mt-3 font-normal text-gray-700 dark:text-gray-400">
          At the <b>subject</b> level, IKno will present questions from the subject as a whole.
        </p>
        <p class="mt-3 font-normal text-gray-700 dark:text-gray-400">
          At the <b>topic</b> level, IKno will present only those questions required relevant to a selected topic.
        </p>
      </a>
    </div>
    <button
      phx-click="list-subjects"
      type="button"
      class="text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 focus:outline-none dark:focus:ring-green-800"
    >
      List of Subjects
    </button>
    """
  end
end
