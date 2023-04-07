defmodule IKno.Knowledge.Subject do
  use Ecto.Schema
  import Ecto.Changeset

  alias IKno.Knowledge.Topic

  schema "subjects" do
    field :description, :string
    field :name, :string
    field :summary, :string
    has_many :topics, Topic

    timestamps()
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:name, :summary, :description])
    |> validate_required([:name, :summary, :description])
  end
end
