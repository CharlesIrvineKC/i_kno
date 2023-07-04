defmodule IKno.Repo.Migrations.AddTypeToQuestion do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :type, :string
    end
  end
end
