defmodule IKno.Repo.Migrations.TopicDescriptonToText do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      modify :description, :text
    end
  end
end
