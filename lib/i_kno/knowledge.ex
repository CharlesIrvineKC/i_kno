defmodule IKno.Knowledge do
  @moduledoc """
  The Knowledge context.
  """

  import Ecto.Query, warn: false
  alias IKno.Repo

  alias IKno.Knowledge.Topic
  alias IKno.Knowledge.TopicRecord
  alias IKno.Knowledge.LearningGoal
  alias IKno.Knowledge.PrereqTopic
  alias Ecto.Adapters.SQL

  # Topics

  def list_topics do
    Repo.all(Topic)
  end

  def find_topics(search_string, subject_id) do
    query = "select id, name, subject_id,
                substr(
                        description,
                        greatest(
                          position('#{search_string}' in description) - 100,
                          1),
                        position('#{search_string}' in description) + 100)
                as description
        from topics
        where description ilike '%#{search_string}%'
        and topics.subject_id = $1"
    {:ok, %{rows: rows, columns: cols}} = SQL.query(Repo, query, [subject_id])
    splice_rows_cols(rows, cols)
  end

  def list_subject_topics!(subject_id) do
    query = from Topic, where: [subject_id: ^subject_id]
    Repo.all(query)
  end

  def is_known(topic_id, user_id) do
    query = "select topic_id from topic_records where topic_id = $1 and user_id = $2"
    {:ok, %{rows: rows}} = SQL.query(Repo, query, [topic_id, user_id])
    length(rows) > 0
  end

  def list_subject_topics(subject_id, user_id) do
    query = "
    select t.id, t.name, t.description, t.subject_id, t.is_task
    from topics t
    where t.subject_id = $1
    order by t.name"
    {:ok, %{rows: rows, columns: cols}} = SQL.query(Repo, query, [subject_id])
    topics = splice_rows_cols(rows, cols)

    if user_id do
      Enum.map(topics, fn topic -> Map.put(topic, :known, is_known(topic.id, user_id)) end)
    else
      Enum.map(topics, fn topic -> Map.put(topic, :known, false) end)
    end
  end

  defp splice_rows_cols(rows, cols) do
    cols = Enum.map(cols, fn col -> String.to_atom(col) end)
    Enum.map(rows, fn row -> Enum.zip(cols, row) |> Map.new() end)
  end

  def get_known(topic_id, user_id) do
    query =
      from TopicRecord,
        where: [topic_id: ^topic_id, user_id: ^user_id]

    length(Repo.all(query)) == 1
  end

  def set_known(attrs) do
    result =
      %TopicRecord{}
      |> TopicRecord.changeset(attrs)
      |> Repo.insert()
  end

  def get_learning(topic_id, user_id) do
    query =
      from LearningGoal,
        where: [topic_id: ^topic_id, user_id: ^user_id],
        select: [:topic_id, :user_id]

    length(Repo.all(query)) == 1
  end

  def set_learning(topic_id, user_id) do
    attrs = %{"topic_id" => topic_id, "user_id" => user_id}

    %LearningGoal{}
    |> LearningGoal.changeset(attrs)
    |> Repo.insert()
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

  def get_topic_name(id), do: get_topic!(id).name

  def get_next_unknown_topic_by_topic(subject_id, topic_id, user_id) do
    query = "with recursive prereqs as
      (select topic_id,
          prereq_id
        from prereq_topics
        where topic_id = $2
        union select p.topic_id,
          p.prereq_id
        from prereq_topics p
        inner join prereqs c on c.prereq_id = p.topic_id)
    select prereq_id
    from prereqs
    where prereq_id not in
    -- where there are no unknown prereqs
        (select t.id
          from topics as t
          left join prereq_topics as pt on t.id = pt.topic_id
          where pt.prereq_id = any
              (select t.id
                from topics t
                where t.subject_id = $1
                -- not in known topics
                  and t.id not in
                    (select kt.topic_id
                      from topic_records as kt
                      where kt.user_id = $3 ) ) )
      and prereq_id not in
        (select kt.topic_id
          from topic_records as kt
          where kt.user_id = $3 )
    group by prereq_id
    limit 1"

    {:ok, result} = SQL.query(Repo, query, [subject_id, topic_id, user_id])

    if length(result.rows) == 1 do
      Enum.map(result.rows, &hd(&1))
      hd(hd(result.rows))
    else
      nil
    end
  end

  def get_unknown_topic_with_unanswered_question(subject_id, testing_topic_id, user_id) do
    unknown_topic_id = get_next_unknown_topic_by_topic(subject_id, testing_topic_id, user_id)

    if unknown_topic_id do
      unanswered_question = get_unanswered_topic_question(unknown_topic_id, user_id)

      if unanswered_question do
        get_topic!(unknown_topic_id)
      else
        attrs = %{
          topic_id: unknown_topic_id,
          subject_id: subject_id,
          user_id: user_id,
          visit_status: :no_questions
        }

        set_known(attrs)
        get_unknown_topic_with_unanswered_question(subject_id, testing_topic_id, user_id)
      end
    end
  end

  def get_next_unknown_subject_topics(subject_id, user_id) do
    query = " -- topics in subject
    select t.id
    from topics as t
    where t.subject_id = $1
    and t.id not in
    (  -- topics with unknown prereqs
        select t.id
        from topics as t
        left join prereq_topics as pt
        on t.id = pt.topic_id
        where pt.prereq_id = any
        (   -- subject topics
            select t.id
            from topics t
            where t.subject_id = $1
            and t.id not in
            (   -- known topics
                select kt.topic_id
                from topic_records as kt
                where kt.user_id = $2
            )
        )
    )
    and t.id not in
    (   -- known topics
        select kt.topic_id
        from topic_records as kt
        where kt.user_id = $2
    )
    group by t.id"

    {:ok, result} = SQL.query(Repo, query, [subject_id, user_id])

    if length(result.rows) > 0 do
      Enum.map(result.rows, &hd(&1))
    else
      []
    end
  end

  def get_next_unknown_subject_topic(subject_id, user_id) do
    query = " -- topics in subject
    select t.id
    from topics as t
    where t.subject_id = $1
    and t.id not in
    (  -- topics with unknown prereqs
        select t.id
        from topics as t
        left join prereq_topics as pt
        on t.id = pt.topic_id
        where pt.prereq_id = any
        (   -- subject topics
            select t.id
            from topics t
            where t.subject_id = $1
            and t.id not in
            (   -- known topics
                select kt.topic_id
                from topic_records as kt
                where kt.user_id = $2
            )
        )
    )
    and t.id not in
    (   -- known topics
        select kt.topic_id
        from topic_records as kt
        where kt.user_id = $2
    )
    group by t.id
    order by random()
    limit 1"

    {:ok, result} = SQL.query(Repo, query, [subject_id, user_id])

    if length(result.rows) > 0 do
      Enum.map(result.rows, &hd(&1))
    else
      []
    end
  end

  def reset_learn_subject_progress(subject_id, user_id) do
    query = "delete from topic_records
             where topic_id in (select id from topics where subject_id = $1)
             and user_id = $2"
    SQL.query(Repo, query, [subject_id, user_id])
  end

  def reset_learn_topic_progress(topic_id, user_id) do
    query = "
      delete from topic_records where user_id = $2
      and topic_id in
      (
      select #{topic_id} as prereq
      union
      (with recursive prereqs as
        (select topic_id,
            prereq_id
          from prereq_topics
          where topic_id = $1
          union select p.topic_id,
            p.prereq_id
          from prereq_topics p
          inner join prereqs c on c.prereq_id = p.topic_id)
      select prereq_id
      from prereqs
    ))"
    SQL.query(Repo, query, [topic_id, user_id])
  end

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end

  # Subjects

  alias IKno.Knowledge.Subject

  def list_subjects do
    query = from s in Subject, order_by: s.name
    Repo.all(query)
  end

  def get_subject!(id), do: Repo.get!(Subject, id)

  def get_subject_name(id), do: get_subject!(id).name

  def create_subject(attrs \\ %{}) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert()
  end

  def update_subject(%Subject{} = subject, attrs) do
    subject
    |> Subject.changeset(attrs)
    |> Repo.update()
  end

  def delete_subject(%Subject{} = subject) do
    Repo.delete(subject)
  end

  def delete_subject_by_id(subject_id) do
    query = "delete from subjects where id = $1"
    {:ok, _result} = SQL.query(Repo, query, [subject_id])
  end

  def change_subject(%Subject{} = subject, attrs \\ %{}) do
    Subject.changeset(subject, attrs)
  end

  # Prerequisties

  def create_prereq(%{topic_id: topic_id, prereq_id: prereq_id} = attrs) do
    cycle = detect_cycle(topic_id, prereq_id)

    if cycle == :ok do
      %PrereqTopic{}
      |> PrereqTopic.changeset(attrs)
      |> Repo.insert()

      :ok
    else
      cycle
    end
  end

  def detect_cycle(topic_id, prereq_id) do
    query = "
    with recursive all_prereqs as(
      select #{topic_id}::bigint topic_id, #{prereq_id}::bigint prereq_id

      union

      select child.topic_id, parent.prereq_id
      from all_prereqs as child
      inner join prereq_topics as parent
      on child.prereq_id = parent.topic_id
    )
    select p.prereq_id, t.name
    from all_prereqs p
    inner join topics t
    on t.id = p.prereq_id"

    {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [])

    if Enum.find(rows, fn row -> hd(row) == topic_id end) do
      rows
    else
      :ok
    end
  end

  def get_immediate_unknown_prereqs(topic_id, user_id) do
    query = "select pt.prereq_id
       from topics as t, prereq_topics as pt, topics as prt
       where t.id = $1
       and pt.topic_id = t.id
       and prt.id = pt.prereq_id
       and prt.id not in
       (
           select kt.topic_id
           from users as u, topic_records as kt, topics as t
           where u.id = kt.user_id
           and t.id = kt.topic_id
           and u.id = $2
       )"
    {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [topic_id, user_id])
    rows
  end

  def suggest_prereqs(substring, subject_id) do
    pattern = "%" <> substring <> "%"

    if subject_id == :all do
      query = "select id, name from topics where name ilike $1"
      {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [pattern])
      Enum.map(rows, fn [topic_id, name] -> {name, topic_id} end) |> Map.new()
    else
      query = "select id, name from topics where subject_id = $1 and name ilike $2"
      {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [subject_id, pattern])
      Enum.map(rows, fn [topic_id, name] -> {name, topic_id} end) |> Map.new()
    end
  end

  def get_topic_prereqs(topic_id) do
    query = "select id, name from topics
            where id in (select prereq_id from prereq_topics where topic_id = $1)"
    {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [topic_id])
    Enum.map(rows, fn [topic_id, name] -> %{topic_id: topic_id, name: name} end)
  end

  def delete_prereq(topic_id, prereq_topic_id) do
    query = "delete from prereq_topics where topic_id = $1 and prereq_id = $2"
    {:ok, _result} = SQL.query(Repo, query, [topic_id, prereq_topic_id])
  end

  def all_subject_prereqs(subject_id) do
    query = "select t.id, pt.prereq_id
             from topics as t
             left join prereq_topics as pt
             on pt.topic_id = t.id
             where t.subject_id = $1"
    {:ok, result} = SQL.query(Repo, query, [subject_id])
    result
  end

  alias IKno.Knowledge.Issue

  @doc """
  Returns the list of issues.

  ## Examples

      iex> list_issues()
      [%Issue{}, ...]

  """
  def list_issues do
    Repo.all(Issue)
  end

  def get_issues_by_subject_id(subject_id) do
    query =
      from Issue,
        where: [subject_id: ^subject_id]

    Repo.all(query)
  end

  @doc """
  Gets a single issue.

  Raises `Ecto.NoResultsError` if the Issue does not exist.

  ## Examples

      iex> get_issue!(123)
      %Issue{}

      iex> get_issue!(456)
      ** (Ecto.NoResultsError)

  """
  def get_issue!(id), do: Repo.get!(Issue, id)

  @doc """
  Creates a issue.

  ## Examples

      iex> create_issue(%{field: value})
      {:ok, %Issue{}}

      iex> create_issue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_issue(attrs \\ %{}) do
    %Issue{}
    |> Issue.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a issue.

  ## Examples

      iex> update_issue(issue, %{field: new_value})
      {:ok, %Issue{}}

      iex> update_issue(issue, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_issue(%Issue{} = issue, attrs) do
    issue
    |> Issue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a issue.

  ## Examples

      iex> delete_issue(issue)
      {:ok, %Issue{}}

      iex> delete_issue(issue)
      {:error, %Ecto.Changeset{}}

  """
  def delete_issue(%Issue{} = issue) do
    Repo.delete(issue)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking issue changes.

  ## Examples

      iex> change_issue(issue)
      %Ecto.Changeset{data: %Issue{}}

  """
  def change_issue(%Issue{} = issue, attrs \\ %{}) do
    Issue.changeset(issue, attrs)
  end

  alias IKno.Knowledge.Question

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions do
    Repo.all(Question)
  end

  def list_questions(topic_id) do
    query = from Question, where: [topic_id: ^topic_id]
    Repo.all(query)
  end

  def get_unanswered_question(subject_id, user_id) do
    query = "
      select q.id, q.question, q.type, q.is_correct, q.topic_id
      from questions q
      left join user_question_statuses s
      on q.id = s.question_id
      where (s.user_id <> $2 or s.user_id is null)
      and q.subject_id = $1
      order by random()
      limit 1"
    {:ok, %{rows: rows, columns: cols}} = SQL.query(Repo, query, [subject_id, user_id])
    result = splice_rows_cols(rows, cols)
    if length(result) == 0, do: nil, else: hd(result)
  end

  def get_unanswered_topic_question(topic_id, user_id) do
    query = "
      select q.id, q.question, q.type, q.is_correct, q.topic_id
      from questions q
      left join user_question_statuses s
      on q.id = s.question_id
      where (s.user_id <> $2 or s.user_id is null)
      and q.topic_id = $1
      order by random()
      limit 1"
    {:ok, %{rows: rows, columns: cols}} = SQL.query(Repo, query, [topic_id, user_id])
    result = splice_rows_cols(rows, cols)
    if length(result) == 0, do: nil, else: hd(result)
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id)

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{data: %Question{}}

  """
  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  alias IKno.Knowledge.Answer

  @doc """
  Returns the list of answers.

  ## Examples

      iex> list_answers()
      [%Answer{}, ...]

  """
  def list_answers do
    Repo.all(Answer)
  end

  def list_answers(question_id) do
    query = from Answer, where: [question_id: ^question_id]
    Repo.all(query)
  end

  @doc """
  Gets a single answer.

  Raises `Ecto.NoResultsError` if the Answer does not exist.

  ## Examples

      iex> get_answer!(123)
      %Answer{}

      iex> get_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_answer!(id), do: Repo.get!(Answer, id)

  @doc """
  Creates a answer.

  ## Examples

      iex> create_answer(%{field: value})
      {:ok, %Answer{}}

      iex> create_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_answer(attrs \\ %{}) do
    %Answer{}
    |> Answer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a answer.

  ## Examples

      iex> update_answer(answer, %{field: new_value})
      {:ok, %Answer{}}

      iex> update_answer(answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_answer(%Answer{} = answer, attrs) do
    answer
    |> Answer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a answer.

  ## Examples

      iex> delete_answer(answer)
      {:ok, %Answer{}}

      iex> delete_answer(answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_answer(%Answer{} = answer) do
    Repo.delete(answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking answer changes.

  ## Examples

      iex> change_answer(answer)
      %Ecto.Changeset{data: %Answer{}}

  """
  def change_answer(%Answer{} = answer, attrs \\ %{}) do
    Answer.changeset(answer, attrs)
  end

  alias IKno.Knowledge.UserQuestionStatus

  @doc """
  Returns the list of user_question_statuses.

  ## Examples

      iex> list_user_question_statuses()
      [%UserQuestionStatus{}, ...]

  """
  def list_user_question_statuses do
    Repo.all(UserQuestionStatus)
  end

  def list_user_question_statuses(question_id, user_id) do
    [1,2]
  end

  @doc """
  Gets a single user_question_status.

  Raises `Ecto.NoResultsError` if the User question status does not exist.

  ## Examples

      iex> get_user_question_status!(123)
      %UserQuestionStatus{}

      iex> get_user_question_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_question_status!(id), do: Repo.get!(UserQuestionStatus, id)

  @doc """
  Creates a user_question_status.

  ## Examples

      iex> create_user_question_status(%{field: value})
      {:ok, %UserQuestionStatus{}}

      iex> create_user_question_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_question_status(attrs \\ %{}) do
    {:ok, question_status} =
      %UserQuestionStatus{}
      |> UserQuestionStatus.changeset(attrs)
      |> Repo.insert()

    if questions_complete(question_status) do
      record_topic_status(question_status)
    end

    {:ok, question_status}
  end

  def questions_complete(question_status) do
    questions = list_questions(question_status.topic_id)
    statuses = list_user_question_statuses(question_status.topic_id, question_status.user_id)
    length(questions) == length(statuses)
  end

  def record_topic_status(question_status) do

  end

  def update_known_topic(question_status) do
    IO.inspect(question_status, label: "question status")
  end

  @doc """
  Updates a user_question_status.

  ## Examples

      iex> update_user_question_status(user_question_status, %{field: new_value})
      {:ok, %UserQuestionStatus{}}

      iex> update_user_question_status(user_question_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_question_status(%UserQuestionStatus{} = user_question_status, attrs) do
    user_question_status
    |> UserQuestionStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_question_status.

  ## Examples

      iex> delete_user_question_status(user_question_status)
      {:ok, %UserQuestionStatus{}}

      iex> delete_user_question_status(user_question_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_question_status(%UserQuestionStatus{} = user_question_status) do
    Repo.delete(user_question_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_question_status changes.

  ## Examples

      iex> change_user_question_status(user_question_status)
      %Ecto.Changeset{data: %UserQuestionStatus{}}

  """
  def change_user_question_status(%UserQuestionStatus{} = user_question_status, attrs \\ %{}) do
    UserQuestionStatus.changeset(user_question_status, attrs)
  end

  alias IKno.Knowledge.TopicRecord

  @doc """
  Returns the list of topic_records.

  ## Examples

      iex> list_topic_records()
      [%TopicRecord{}, ...]

  """
  def list_topic_records do
    Repo.all(TopicRecord)
  end

  @doc """
  Gets a single topic_record.

  Raises `Ecto.NoResultsError` if the Topic record does not exist.

  ## Examples

      iex> get_topic_record!(123)
      %TopicRecord{}

      iex> get_topic_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic_record!(id), do: Repo.get!(TopicRecord, id)

  @doc """
  Creates a topic_record.

  ## Examples

      iex> create_topic_record(%{field: value})
      {:ok, %TopicRecord{}}

      iex> create_topic_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic_record(attrs \\ %{}) do
    %TopicRecord{}
    |> TopicRecord.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a topic_record.

  ## Examples

      iex> update_topic_record(topic_record, %{field: new_value})
      {:ok, %TopicRecord{}}

      iex> update_topic_record(topic_record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic_record(%TopicRecord{} = topic_record, attrs) do
    topic_record
    |> TopicRecord.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a topic_record.

  ## Examples

      iex> delete_topic_record(topic_record)
      {:ok, %TopicRecord{}}

      iex> delete_topic_record(topic_record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_topic_record(%TopicRecord{} = topic_record) do
    Repo.delete(topic_record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic_record changes.

  ## Examples

      iex> change_topic_record(topic_record)
      %Ecto.Changeset{data: %TopicRecord{}}

  """
  def change_topic_record(%TopicRecord{} = topic_record, attrs \\ %{}) do
    TopicRecord.changeset(topic_record, attrs)
  end
end
