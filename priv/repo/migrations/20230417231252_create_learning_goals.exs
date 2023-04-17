defmodule IKno.Repo.Migrations.CreateLearningGoals do
  use Ecto.Migration

  def change do
    create table(:learning_goals, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing), primary_key: true
      add :topic_id, references(:topics, on_delete: :nothing), primary_key: true

      timestamps()
    end

    create index(:learning_goals, [:user_id])
    create index(:learning_goals, [:topic_id])
  end
end
