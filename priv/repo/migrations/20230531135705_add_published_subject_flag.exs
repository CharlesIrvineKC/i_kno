defmodule IKno.Repo.Migrations.AddPublishedSubjectFlag do
  use Ecto.Migration

  def change do
    alter table(:subjects) do
      add :is_published, :boolean
    end
  end
end
