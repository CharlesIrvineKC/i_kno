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
end
