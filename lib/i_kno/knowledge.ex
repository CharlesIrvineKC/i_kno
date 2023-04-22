defmodule IKno.Knowledge do
  @moduledoc """
  The Knowledge context.
  """

  import Ecto.Query, warn: false
  alias IKno.Repo

  alias IKno.Knowledge.Topic
  alias IKno.Knowledge.KnownTopic
  alias IKno.Knowledge.LearningGoal
  alias IKno.Knowledge.PrereqTopic
  alias Ecto.Adapters.SQL

  # Topics

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

    if length(rows) == 0 do
      nil
    else
      topic_ids = Enum.map(rows, &(hd(&1)))
      unknown_prereq_id = Enum.find(topic_ids, fn topic_id -> get_unknown_prereqs(topic_id, user_id) end)
      get_topic!(unknown_prereq_id)
    end
  end

  def reset_subject_progress(subject_id, user_id) do
    query = "delete from known_topics
             where topic_id in (select id from topics where subject_id = $1)
             and user_id = $2"
    SQL.query(Repo, query, [subject_id, user_id])
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

  # Subjects

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

  # Prerequisties

  def create_prereq(attrs) do
    %PrereqTopic{}
    |> PrereqTopic.changeset(attrs)
    |> Repo.insert()
  end

  def get_unknown_prereqs(topic_id, user_id) do
    query =
      "select pt.prereq_id
       from topics as t, prereq_topics as pt, topics as prt
       where t.id = $1
       and pt.topic_id = t.id
       and prt.id = pt.prereq_id
       and prt.id not in
       (
           select kt.topic_id
           from users as u, known_topics as kt, topics as t
           where u.id = kt.user_id
           and t.id = kt.topic_id
           and u.id = $2
       )"
       {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [topic_id, user_id])
       rows
  end

  def get_next_unknown_prereqs(topic_id, user_id) do
    get_unknowns(get_unknown_prereqs(topic_id, user_id), user_id)
  end

  def get_unknowns([], _user_id), do: []
  def get_unknowns([topic_id | topic_ids], user_id) do
    Enum.concat(get_unknown_prereqs(topic_id, user_id), get_unknowns(topic_ids, user_id))
  end

  def suggest_prereqs(substring, subject_id) do
    query = "select id, name from topics where subject_id = $1 and name like $2"
    pattern = "%" <> substring <> "%"
    {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [subject_id, pattern])
    Enum.map(rows, fn ([topic_id, name]) -> {name, topic_id} end) |> Map.new()
  end

  def get_prereqs(topic_id) do
    query = "select id, name from topics
            where id in (select prereq_id from prereq_topics where topic_id = $1)"
    {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [topic_id])
    Enum.map(rows, fn ([topic_id, name]) -> %{topic_id: topic_id, name: name} end)
  end
end
