defmodule IKno.Repo.Migrations.DropKnownTopicsTable do
  use Ecto.Migration

  def change do
    drop table("known_topics")
  end
end
