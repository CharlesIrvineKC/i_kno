defmodule IKno.Repo.Migrations.CreateKnownTopics do
  use Ecto.Migration

  def change do
    create table(:known_topics, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing), primary_key: true
      add :topic_id, references(:topics, on_delete: :nothing), primary_key: true

      timestamps()
    end

    create index(:known_topics, [:user_id])
    create index(:known_topics, [:topic_id])
  end
end
