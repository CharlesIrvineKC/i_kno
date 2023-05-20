defmodule IKno.Repo.Migrations.CreateIssues do
  use Ecto.Migration

  def change do
    create table(:issues) do
      add :description, :string
      add :status, :string
      add :resolution, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :topic_id, references(:topics, on_delete: :nothing)
      add :subject_id, references(:subjects, on_delete: :nothing)

      timestamps()
    end

    create index(:issues, [:user_id])
    create index(:issues, [:topic_id])
    create index(:issues, [:subject_id])
  end
end
