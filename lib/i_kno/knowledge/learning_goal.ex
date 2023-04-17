defmodule IKno.Knowledge.LearningGoal do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "learning_goals" do

    field :user_id, :id
    field :topic_id, :id

    timestamps()
  end

  @doc false
  def changeset(learning_goal, attrs) do
    learning_goal
    |> cast(attrs, [:user_id, :topic_id])
    |> validate_required([:user_id, :topic_id])
  end
end
