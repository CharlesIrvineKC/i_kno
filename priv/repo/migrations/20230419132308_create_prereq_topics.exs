defmodule IKno.Repo.Migrations.CreatePrereqTopics do
  use Ecto.Migration

  def change do
    create table(:prereq_topics) do
      add :topic_id, references(:topics, on_delete: :nothing)
      add :prereq_id, references(:topics, on_delete: :nothing)

      timestamps()
    end

    create index(:prereq_topics, [:topic_id])
    create index(:prereq_topics, [:prereq_id])
  end
end
