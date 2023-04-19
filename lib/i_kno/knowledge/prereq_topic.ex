defmodule IKno.Knowledge.PrereqTopic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prereq_topics" do

    field :topic_id, :id
    field :prereq_id, :id

    timestamps()
  end

  @doc false
  def changeset(prereq_topic, attrs) do
    prereq_topic
    |> cast(attrs, [:topic_id, :prereq_id])
    |> validate_required([:topic_id, :prereq_id])
  end
end
