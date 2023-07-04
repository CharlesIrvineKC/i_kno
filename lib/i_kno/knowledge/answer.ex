defmodule IKno.Knowledge.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "answers" do
    field :answer, :string
    field :is_correct, :boolean, default: false
    field :question_id, :id

    timestamps()
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:answer, :is_correct])
    |> validate_required([:answer, :is_correct])
  end
end
