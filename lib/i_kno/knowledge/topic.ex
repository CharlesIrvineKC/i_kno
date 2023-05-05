defmodule IKno.Knowledge.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  alias IKno.Knowledge.Subject

  schema "topics" do
    field :description, :string
    field :name, :string
    field :is_task, :boolean
    belongs_to :subject, Subject

    timestamps()
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:name, :description, :subject_id, :is_task])
    |> validate_required([:name, :description, :subject_id, :is_task])
  end
end
