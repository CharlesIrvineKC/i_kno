defmodule IKno.Repo do
  use Ecto.Repo,
    otp_app: :i_kno,
    adapter: Ecto.Adapters.Postgres
end
