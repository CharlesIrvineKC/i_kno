defmodule IKno.Knowledge.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :question, :string
    field :topic_id, :id
    field :type, Ecto.Enum, values: [:true_false, :multiple_choice]

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question])
    |> validate_required([:question])
  end
end
