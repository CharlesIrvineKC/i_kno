defmodule IKno.Knowledge.Subject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subjects" do
    field :description, :string
    field :name, :string
    field :summary, :string

    timestamps()
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:name, :summary, :description])
    |> validate_required([:name, :summary, :description])
  end
end
