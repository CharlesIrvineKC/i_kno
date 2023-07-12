defmodule IKno.Knowledge.UserQuestionStatus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_question_statuses" do
    field :status, Ecto.Enum, values: [:passed, :failed]
    field :question_id, :id
    field :user_id, :id
    field :topic_id, :id
    field :subject_id, :id

    timestamps()
  end

  @doc false
  def changeset(user_question_status, attrs) do
    user_question_status
    |> cast(attrs, [:status, :question_id, :user_id, :topic_id, :subject_id])
    |> validate_required([:status, :question_id, :user_id, :topic_id, :subject_id])
  end
end
