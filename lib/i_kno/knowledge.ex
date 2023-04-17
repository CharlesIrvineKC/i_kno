defmodule IKno.Knowledge do
  @moduledoc """
  The Knowledge context.
  """

  import Ecto.Query, warn: false
  alias IKno.Repo

  alias IKno.Knowledge.Topic
  alias IKno.Knowledge.KnownTopic

  def list_topics do
    Repo.all(Topic)
  end

  def list_subject_topics(subject_id) do
    query = from Topic, where: [subject_id: ^subject_id]
    Repo.all(query)
  end

  def get_known(topic_id, user_id) do
    IO.inspect([topic_id, user_id], label: "********** topic user *********")
    query =
      from "known_topics",
      where: [topic_id: ^topic_id, user_id: ^user_id],
      select: [:topic_id, :user_id]
    length(Repo.all(query)) == 1
  end

  def set_known(topic_id, user_id) do
    attrs = %{"topic_id" => topic_id, "user_id" => user_id}
    %KnownTopic{}
    |> KnownTopic.changeset(attrs)
    |> Repo.insert()
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

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
