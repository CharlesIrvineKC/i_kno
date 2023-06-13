defmodule IKno.Repo.Migrations.CascadeDeleteSubjectAdmins do
  use Ecto.Migration

  def change do

    drop constraint(:subject_admins, :subject_admins_subject_id_fkey)
    drop constraint(:subject_admins, :subject_admins_user_id_fkey)

    alter table(:subject_admins) do

      modify :subject_id, references(:subjects, on_delete: :delete_all)
      modify :user_id, references(:users, on_delete: :delete_all)

    end
  end
end
