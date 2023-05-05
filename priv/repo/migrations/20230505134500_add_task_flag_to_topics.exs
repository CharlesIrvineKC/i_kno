defmodule IKno.Repo.Migrations.AddTaskFlagToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :is_task, :boolean
    end
  end
end
