defmodule IKno.Repo.Migrations.AddTestedFlagToKnownTopics do
  use Ecto.Migration

  def change do
    alter table(:known_topics) do
      add :is_tested, :boolean
    end
  end
end
