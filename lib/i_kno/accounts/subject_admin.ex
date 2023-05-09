defmodule IKno.Accounts.SubjectAdmin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subject_admins" do

    field :subject_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(subject_admin, attrs) do
    subject_admin
    |> cast(attrs, [:subject_id, :user_id])
    |> validate_required([:subject_id, :user_id])
  end
end
