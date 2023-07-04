defmodule IKno.KnowledgeTest do
  use IKno.DataCase

  alias IKno.Knowledge

  describe "topics" do
    alias IKno.Knowledge.Topic

    import IKno.KnowledgeFixtures

    @invalid_attrs %{description: nil, name: nil}

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      assert Knowledge.list_topics() == [topic]
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      assert Knowledge.get_topic!(topic.id) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %Topic{} = topic} = Knowledge.create_topic(valid_attrs)
      assert topic.description == "some description"
      assert topic.name == "some name"
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Knowledge.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %Topic{} = topic} = Knowledge.update_topic(topic, update_attrs)
      assert topic.description == "some updated description"
      assert topic.name == "some updated name"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Knowledge.update_topic(topic, @invalid_attrs)
      assert topic == Knowledge.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Knowledge.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> Knowledge.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Knowledge.change_topic(topic)
    end
  end

  describe "subjects" do
    alias IKno.Knowledge.Subject

    import IKno.KnowledgeFixtures

    @invalid_attrs %{description: nil, name: nil, summary: nil}

    test "list_subjects/0 returns all subjects" do
      subject = subject_fixture()
      assert Knowledge.list_subjects() == [subject]
    end

    test "get_subject!/1 returns the subject with given id" do
      subject = subject_fixture()
      assert Knowledge.get_subject!(subject.id) == subject
    end

    test "create_subject/1 with valid data creates a subject" do
      valid_attrs = %{description: "some description", name: "some name", summary: "some summary"}

      assert {:ok, %Subject{} = subject} = Knowledge.create_subject(valid_attrs)
      assert subject.description == "some description"
      assert subject.name == "some name"
      assert subject.summary == "some summary"
    end

    test "create_subject/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Knowledge.create_subject(@invalid_attrs)
    end

    test "update_subject/2 with valid data updates the subject" do
      subject = subject_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name", summary: "some updated summary"}

      assert {:ok, %Subject{} = subject} = Knowledge.update_subject(subject, update_attrs)
      assert subject.description == "some updated description"
      assert subject.name == "some updated name"
      assert subject.summary == "some updated summary"
    end

    test "update_subject/2 with invalid data returns error changeset" do
      subject = subject_fixture()
      assert {:error, %Ecto.Changeset{}} = Knowledge.update_subject(subject, @invalid_attrs)
      assert subject == Knowledge.get_subject!(subject.id)
    end

    test "delete_subject/1 deletes the subject" do
      subject = subject_fixture()
      assert {:ok, %Subject{}} = Knowledge.delete_subject(subject)
      assert_raise Ecto.NoResultsError, fn -> Knowledge.get_subject!(subject.id) end
    end

    test "change_subject/1 returns a subject changeset" do
      subject = subject_fixture()
      assert %Ecto.Changeset{} = Knowledge.change_subject(subject)
    end
  end

  describe "issues" do
    alias IKno.Knowledge.Issue

    import IKno.KnowledgeFixtures

    @invalid_attrs %{description: nil, resolution: nil, status: nil}

    test "list_issues/0 returns all issues" do
      issue = issue_fixture()
      assert Knowledge.list_issues() == [issue]
    end

    test "get_issue!/1 returns the issue with given id" do
      issue = issue_fixture()
      assert Knowledge.get_issue!(issue.id) == issue
    end

    test "create_issue/1 with valid data creates a issue" do
      valid_attrs = %{description: "some description", resolution: "some resolution", status: :open}

      assert {:ok, %Issue{} = issue} = Knowledge.create_issue(valid_attrs)
      assert issue.description == "some description"
      assert issue.resolution == "some resolution"
      assert issue.status == :open
    end

    test "create_issue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Knowledge.create_issue(@invalid_attrs)
    end

    test "update_issue/2 with valid data updates the issue" do
      issue = issue_fixture()
      update_attrs = %{description: "some updated description", resolution: "some updated resolution", status: :closed}

      assert {:ok, %Issue{} = issue} = Knowledge.update_issue(issue, update_attrs)
      assert issue.description == "some updated description"
      assert issue.resolution == "some updated resolution"
      assert issue.status == :closed
    end

    test "update_issue/2 with invalid data returns error changeset" do
      issue = issue_fixture()
      assert {:error, %Ecto.Changeset{}} = Knowledge.update_issue(issue, @invalid_attrs)
      assert issue == Knowledge.get_issue!(issue.id)
    end

    test "delete_issue/1 deletes the issue" do
      issue = issue_fixture()
      assert {:ok, %Issue{}} = Knowledge.delete_issue(issue)
      assert_raise Ecto.NoResultsError, fn -> Knowledge.get_issue!(issue.id) end
    end

    test "change_issue/1 returns a issue changeset" do
      issue = issue_fixture()
      assert %Ecto.Changeset{} = Knowledge.change_issue(issue)
    end
  end

  describe "questions" do
    alias IKno.Knowledge.Question

    import IKno.KnowledgeFixtures

    @invalid_attrs %{question: nil}

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Knowledge.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Knowledge.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{question: "some question"}

      assert {:ok, %Question{} = question} = Knowledge.create_question(valid_attrs)
      assert question.question == "some question"
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Knowledge.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{question: "some updated question"}

      assert {:ok, %Question{} = question} = Knowledge.update_question(question, update_attrs)
      assert question.question == "some updated question"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Knowledge.update_question(question, @invalid_attrs)
      assert question == Knowledge.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Knowledge.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Knowledge.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Knowledge.change_question(question)
    end
  end

  describe "answers" do
    alias IKno.Knowledge.Answer

    import IKno.KnowledgeFixtures

    @invalid_attrs %{answer: nil, is_correct: nil}

    test "list_answers/0 returns all answers" do
      answer = answer_fixture()
      assert Knowledge.list_answers() == [answer]
    end

    test "get_answer!/1 returns the answer with given id" do
      answer = answer_fixture()
      assert Knowledge.get_answer!(answer.id) == answer
    end

    test "create_answer/1 with valid data creates a answer" do
      valid_attrs = %{answer: "some answer", is_correct: true}

      assert {:ok, %Answer{} = answer} = Knowledge.create_answer(valid_attrs)
      assert answer.answer == "some answer"
      assert answer.is_correct == true
    end

    test "create_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Knowledge.create_answer(@invalid_attrs)
    end

    test "update_answer/2 with valid data updates the answer" do
      answer = answer_fixture()
      update_attrs = %{answer: "some updated answer", is_correct: false}

      assert {:ok, %Answer{} = answer} = Knowledge.update_answer(answer, update_attrs)
      assert answer.answer == "some updated answer"
      assert answer.is_correct == false
    end

    test "update_answer/2 with invalid data returns error changeset" do
      answer = answer_fixture()
      assert {:error, %Ecto.Changeset{}} = Knowledge.update_answer(answer, @invalid_attrs)
      assert answer == Knowledge.get_answer!(answer.id)
    end

    test "delete_answer/1 deletes the answer" do
      answer = answer_fixture()
      assert {:ok, %Answer{}} = Knowledge.delete_answer(answer)
      assert_raise Ecto.NoResultsError, fn -> Knowledge.get_answer!(answer.id) end
    end

    test "change_answer/1 returns a answer changeset" do
      answer = answer_fixture()
      assert %Ecto.Changeset{} = Knowledge.change_answer(answer)
    end
  end
end
