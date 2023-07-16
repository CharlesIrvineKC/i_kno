defmodule IKno.Knowledge.KnownTopic do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "known_topics" do

    field :user_id, :id
    field :topic_id, :id
    field :is_tested, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(known_topic, attrs) do
    known_topic
    |> cast(attrs, [:user_id, :topic_id, :is_tested])
    |> validate_required([:user_id, :topic_id])
  end
end
