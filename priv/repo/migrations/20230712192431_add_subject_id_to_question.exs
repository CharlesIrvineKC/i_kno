defmodule IKno.Repo.Migrations.AddSubjectIdToQuestion do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :subject_id, references(:subjects, on_delete: :delete_all)
    end

    create index(:questions, [:subject_id])
  end
end
