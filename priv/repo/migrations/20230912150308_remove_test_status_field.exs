defmodule IKno.Repo.Migrations.RemoveTestStatusField do
  use Ecto.Migration

  def change do
    alter table(:topic_records) do
      remove :test_status, :string
    end
  end
end
