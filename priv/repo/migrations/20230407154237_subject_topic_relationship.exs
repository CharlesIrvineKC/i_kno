defmodule IKno.Repo.Migrations.SubjectTopicRelationship do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :subject_id, references(:subjects)
    end
  end
end
