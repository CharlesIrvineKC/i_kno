defmodule IKno.Repo.Migrations.CreateSubjects do
  use Ecto.Migration

  def change do
    create table(:subjects) do
      add :name, :string
      add :summary, :string
      add :description, :string

      timestamps()
    end
  end
end
