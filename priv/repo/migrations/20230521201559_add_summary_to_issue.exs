defmodule IKno.Repo.Migrations.AddSummaryToIssue do
  use Ecto.Migration

  def change do
    alter table(:issues) do
      add :summary, :string
    end
  end
end
