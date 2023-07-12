defmodule IKno.Repo.Migrations.CreateUserQuestionStatuses do
  use Ecto.Migration

  def change do
    create table(:user_question_statuses) do
      add :status, :string
      add :question_id, references(:questions, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :topic_id, references(:topics, on_delete: :delete_all)
      add :subject_id, references(:subjects, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_question_statuses, [:question_id])
    create index(:user_question_statuses, [:user_id])
    create index(:user_question_statuses, [:topic_id])
    create index(:user_question_statuses, [:subject_id])
  end
end
