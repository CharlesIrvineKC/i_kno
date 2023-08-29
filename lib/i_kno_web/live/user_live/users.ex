defmodule IKnoWeb.Users do
  use IKnoWeb, :live_view

  alias IKno.Accounts

  def mount(_params, session, socket) do
    user_token = Map.get(session, "user_token")

    is_super_user =
      if user_token do
        user = Accounts.get_user_by_session_token(user_token)
        user.id == 2
      else
        false
      end

    users = Accounts.list_users
    {:ok, assign(socket, users: users, is_super_user: is_super_user)}
  end

  def render(assigns) do
    ~H"""
    <div :if={@is_super_user} class="relative overflow-x-auto">
      <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
        <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
          <tr>
            <th scope="col" class="px-6 py-3">
              Email
            </th>
          </tr>
        </thead>
        <tbody>
          <tr :for={user <- @users}
              class="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
            <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white">
              <%= user.email %>
            </th>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
