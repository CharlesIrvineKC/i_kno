defmodule IKno.Repo.Migrations.CascadeDeleteTopicKnownTopics do
  use Ecto.Migration

  def change do
    drop constraint(:known_topics, :known_topics_user_id_fkey)
    drop constraint(:known_topics, :known_topics_topic_id_fkey)

    alter table(:known_topics) do
      modify :user_id, references(:users, on_delete: :delete_all)
      modify :topic_id, references(:topics, on_delete: :delete_all)
    end
  end
end
