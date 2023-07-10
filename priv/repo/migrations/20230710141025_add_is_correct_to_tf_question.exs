defmodule IKno.Repo.Migrations.AddIsCorrectToTfQuestion do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :is_correct, :boolean
    end
  end
end
