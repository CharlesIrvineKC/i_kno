defmodule IKno.Repo.Migrations.SubjectDescriptonToText do
  use Ecto.Migration

  def change do
    alter table(:subjects) do
      modify :description, :text
    end
  end
end
