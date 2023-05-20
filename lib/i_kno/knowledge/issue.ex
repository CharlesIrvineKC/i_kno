defmodule IKno.Knowledge.Issue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "issues" do
    field :description, :string
    field :resolution, :string
    field :status, Ecto.Enum, values: [:open, :closed]
    field :user_id, :id
    field :topic_id, :id
    field :subject_id, :id

    timestamps()
  end

  @doc false
  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:description, :status, :resolution, :user_id, :topic_id, :subject_id])
    |> validate_required([:description, :status, :user_id, :topic_id, :subject_id])
  end
end
