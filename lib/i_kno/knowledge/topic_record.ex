defmodule IKno.Knowledge.TopicRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topic_records" do
    field :visit_status, Ecto.Enum, values: [:known, :skip, :no_questions]
    field :topic_id, :id
    field :subject_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(topic_record, attrs) do
    topic_record
    |> cast(attrs, [:visit_status, :topic_id, :subject_id, :user_id])
    |> validate_required([:visit_status, :topic_id, :subject_id, :user_id])
  end
end
