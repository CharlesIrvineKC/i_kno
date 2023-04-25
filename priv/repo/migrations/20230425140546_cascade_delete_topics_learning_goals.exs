defmodule IKno.Repo.Migrations.CascadeDeleteTopicsLearningGoals do
  use Ecto.Migration

  def change do
    drop constraint(:learning_goals, :learning_goals_topic_id_fkey)
    drop constraint(:learning_goals, :learning_goals_user_id_fkey)

    alter table(:learning_goals, primary_key: false) do
      modify :user_id, references(:users, on_delete: :delete_all)
      modify :topic_id, references(:topics, on_delete: :delete_all)
    end
  end
end
