defmodule IKno.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :name, :string
      add :description, :string

      timestamps()
    end
  end
end
