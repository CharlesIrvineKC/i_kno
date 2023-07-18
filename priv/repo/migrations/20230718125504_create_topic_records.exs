defmodule IKno.Repo.Migrations.CreateTopicRecords do
  use Ecto.Migration

  def change do
    create table(:topic_records) do
      add :visit_status, :string
      add :test_status, :string
      add :topic_id, references(:topics, on_delete: :delete_all)
      add :subject_id, references(:subjects, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:topic_records, [:topic_id])
    create index(:topic_records, [:subject_id])
    create index(:topic_records, [:user_id])
  end
end
