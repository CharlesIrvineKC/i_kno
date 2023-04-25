defmodule IKno.Repo.Migrations.CascadeDeleteSubjectTopics do
  use Ecto.Migration

  def change do
    drop constraint(:topics, :topics_subject_id_fkey)

    alter table(:topics) do
      modify :subject_id, references(:subjects, on_delete: :delete_all)
    end
  end
end
