defmodule IKno.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `IKno.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> IKno.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a subject_admin.
  """
  def subject_admin_fixture(attrs \\ %{}) do
    {:ok, subject_admin} =
      attrs
      |> Enum.into(%{

      })
      |> IKno.Accounts.create_subject_admin()

    subject_admin
  end
end
