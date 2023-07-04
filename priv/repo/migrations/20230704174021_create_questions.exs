defmodule IKno.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :question, :text
      add :topic_id, references(:topics, on_delete: :delete_all)

      timestamps()
    end

    create index(:questions, [:topic_id])
  end
end
