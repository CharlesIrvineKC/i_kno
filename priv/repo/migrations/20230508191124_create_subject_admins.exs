defmodule IKno.Repo.Migrations.CreateSubjectAdmins do
  use Ecto.Migration

  def change do
    create table(:subject_admins) do
      add :subject_id, references(:subjects, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:subject_admins, [:subject_id])
    create index(:subject_admins, [:user_id])
  end
end
