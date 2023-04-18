defmodule IKno.Knowledge do
  @moduledoc """
  The Knowledge context.
  """

  import Ecto.Query, warn: false
  alias IKno.Repo

  alias IKno.Knowledge.Topic
  alias IKno.Knowledge.KnownTopic
  alias IKno.Knowledge.LearningGoal
  alias Ecto.Adapters.SQL

  def list_topics do
    Repo.all(Topic)
  end

  def list_subject_topics(subject_id) do
    query = from Topic, where: [subject_id: ^subject_id]
    Repo.all(query)
  end

  def get_known(topic_id, user_id) do
    query =
      from KnownTopic,
        where: [topic_id: ^topic_id, user_id: ^user_id]

    length(Repo.all(query)) == 1
  end

  def set_known(topic_id, user_id) do
    attrs = %{"topic_id" => topic_id, "user_id" => user_id}

    %KnownTopic{}
    |> KnownTopic.changeset(attrs)
    |> Repo.insert()
  end

  def get_learning(topic_id, user_id) do
    query =
      from LearningGoal,
        where: [topic_id: ^topic_id, user_id: ^user_id],
        select: [:topic_id, :user_id]

    length(Repo.all(query)) == 1
  end

  def set_learning(topic_id, user_id) do
    attrs = %{"topic_id" => topic_id, "user_id" => user_id}

    %LearningGoal{}
    |> LearningGoal.changeset(attrs)
    |> Repo.insert()
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

  def get_unknown_topic(subject_id, user_id) do
    query = "select id from topics
             where subject_id = $1
             and id not in (select topic_id from known_topics where user_id = $2)"
    {:ok, %{:rows => rows}} = SQL.query(Repo, query, [subject_id, user_id])

    if length(rows) > 0 do
      [[topic_id] | _rest] = rows
      get_topic!(topic_id)
    end
  end

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end

  alias IKno.Knowledge.Subject

  def list_subjects do
    Repo.all(Subject)
  end

  def get_subject!(id), do: Repo.get!(Subject, id)

  def create_subject(attrs \\ %{}) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert()
  end

  def update_subject(%Subject{} = subject, attrs) do
    subject
    |> Subject.changeset(attrs)
    |> Repo.update()
  end

  def delete_subject(%Subject{} = subject) do
    Repo.delete(subject)
  end

  def change_subject(%Subject{} = subject, attrs \\ %{}) do
    Subject.changeset(subject, attrs)
  end
end
