defmodule IKnoWeb.TopicLive.TestTopic do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Accounts

  def mount(%{"subject_id" => subject_id, "topic_id" => topic_id}, %{"user_token" => user_token}, socket) do
    subject_id = String.to_integer(subject_id)
    testing_topic = Knowledge.get_topic!(String.to_integer(topic_id))
    subject = Knowledge.get_subject!(subject_id)
    user = Accounts.get_user_by_session_token(user_token)
    prereqs = if testing_topic, do: Knowledge.get_topic_prereqs(testing_topic.id), else: []
    is_known = if testing_topic, do: Knowledge.get_known(testing_topic.id, user.id), else: nil

    socket =
      assign(
        socket,
        subject: subject,
        user: user,
        testing_topic: testing_topic,
        is_known: is_known,
        prereqs: prereqs,
        mode: :learn_topic,
        page_title: "Test: " <> testing_topic.name
      )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

    """
  end
end
