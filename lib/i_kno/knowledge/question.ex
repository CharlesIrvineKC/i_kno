defmodule IKno.Knowledge.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :question, :string
    field :topic_id, :id
    field :subject_id, :id
    field :type, Ecto.Enum, values: [:true_false, :multiple_choice]
    field :is_correct, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question, :topic_id, :subject_id, :type, :is_correct])
    |> validate_required([:question, :topic_id, :subject_id, :type])
  end
end
