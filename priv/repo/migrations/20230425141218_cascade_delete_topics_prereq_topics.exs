defmodule IKno.Repo.Migrations.CascadeDeleteTopicsPrereqTopics do
  use Ecto.Migration

  def change do
    drop constraint(:prereq_topics, :prereq_topics_topic_id_fkey)
    drop constraint(:prereq_topics, :prereq_topics_prereq_id_fkey)

    alter table(:prereq_topics) do
      modify :topic_id, references(:topics, on_delete: :delete_all)
      modify :prereq_id, references(:topics, on_delete: :delete_all)
    end
  end
end
