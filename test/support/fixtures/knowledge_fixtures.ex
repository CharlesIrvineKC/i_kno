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

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        question: "some question"
      })
      |> IKno.Knowledge.create_question()

    question
  end

  @doc """
  Generate a answer.
  """
  def answer_fixture(attrs \\ %{}) do
    {:ok, answer} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        is_correct: true
      })
      |> IKno.Knowledge.create_answer()

    answer
  end

  @doc """
  Generate a user_question_status.
  """
  def user_question_status_fixture(attrs \\ %{}) do
    {:ok, user_question_status} =
      attrs
      |> Enum.into(%{
        status: :passed
      })
      |> IKno.Knowledge.create_user_question_status()

    user_question_status
  end

  @doc """
  Generate a topic_record.
  """
  def topic_record_fixture(attrs \\ %{}) do
    {:ok, topic_record} =
      attrs
      |> Enum.into(%{
        visit_status: "some visit_status"
      })
      |> IKno.Knowledge.create_topic_record()

    topic_record
  end
end
