defmodule IKno.KnowledgeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `IKno.Knowledge` context.
  """

  @doc """
  Generate a topic.
  """
  def topic_fixture(attrs \\ %{}) do
    {:ok, topic} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> IKno.Knowledge.create_topic()

    topic
  end

  @doc """
  Generate a subject.
  """
  def subject_fixture(attrs \\ %{}) do
    {:ok, subject} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        summary: "some summary"
      })
      |> IKno.Knowledge.create_subject()

    subject
  end

  @doc """
  Generate a issue.
  """
  def issue_fixture(attrs \\ %{}) do
    {:ok, issue} =
      attrs
      |> Enum.into(%{
        description: "some description",
        resolution: "some resolution",
        status: :open
      })
      |> IKno.Knowledge.create_issue()

    issue
  end
end
