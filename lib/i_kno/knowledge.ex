defmodule IKno.Knowledge do
  @moduledoc """
  The Knowledge context.
  """

  import Ecto.Query, warn: false
  alias IKno.Repo

  alias IKno.Knowledge.Topic
  alias IKno.Knowledge.KnownTopic
  alias IKno.Knowledge.LearningGoal
  alias IKno.Knowledge.PrereqTopic
  alias Ecto.Adapters.SQL

  # Topics

  def list_topics do
    Repo.all(Topic)
  end

  def find_topics(search_string) do
    query =
      "select id, name, subject_id,
                substr(
                        description,
                        greatest(
                          position('#{search_string}' in description) - 100,
                          1),
                        position('#{search_string}' in description) + 100)
                as description
        from topics
        where description like '%#{search_string}%'"
    {:ok, %{rows: rows, columns: cols}} = SQL.query(Repo, query, [])
    splice_rows_cols(rows, cols)
  end

  def list_subject_topics!(subject_id) do
    query = from Topic, where: [subject_id: ^subject_id]
    Repo.all(query)
  end

  def list_subject_topics(subject_id, user_id) do
    query = "
    select t.id, t.name, t.description, t.subject_id, t.is_task, (kt.topic_id is not null) as known
    from topics t
    left join known_topics kt
    on t.id = kt.topic_id
    where t.subject_id = $1
    and (kt.user_id = $2
    or kt.topic_id is null)"
    {:ok, %{rows: rows, columns: cols}} = SQL.query(Repo, query, [subject_id, user_id])
    splice_rows_cols(rows, cols)
  end

  defp splice_rows_cols(rows, cols) do
    cols = Enum.map(cols, fn col -> String.to_atom(col) end)
    Enum.map(rows, fn row -> Enum.zip(cols, row) |> Map.new() end)
  end

  def get_known(topic_id, user_id) do
    query =
      from KnownTopic,
        where: [topic_id: ^topic_id, user_id: ^user_id]

    length(Repo.all(query)) == 1
  end

  def set_known(topic_id, user_id) do
    attrs = %{"topic_id" => topic_id, "user_id" => user_id}

    %KnownTopic{}
    |> KnownTopic.changeset(attrs)
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

  def get_next_unknown_topic_topics(subject_id, topic_id, user_id) do
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
                      from known_topics as kt
                      where kt.user_id = $3 ) ) )
      and prereq_id not in
        (select kt.topic_id
          from known_topics as kt
          where kt.user_id = $3 )
    group by prereq_id"

    {:ok, result} = SQL.query(Repo, query, [subject_id, topic_id, user_id])

    if length(result.rows) > 0 do
      Enum.map(result.rows, &hd(&1))
    else
      []
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
                from known_topics as kt
                where kt.user_id = $2
            )
        )
    )
    and t.id not in
    (   -- known topics
        select kt.topic_id
        from known_topics as kt
        where kt.user_id = 2
    )
    group by t.id"

    {:ok, result} = SQL.query(Repo, query, [subject_id, user_id])

    if length(result.rows) > 0 do
      Enum.map(result.rows, &hd(&1))
    else
      []
    end
  end

  def reset_learn_subject_progress(subject_id, user_id) do
    query = "delete from known_topics
             where topic_id in (select id from topics where subject_id = $1)
             and user_id = $2"
    SQL.query(Repo, query, [subject_id, user_id])
  end

  def reset_learn_topic_progress(topic_id, user_id) do
    query = "
      delete from known_topics where user_id = $2
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
    Repo.all(Subject)
  end

  def get_subject!(id), do: Repo.get!(Subject, id)

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
           from users as u, known_topics as kt, topics as t
           where u.id = kt.user_id
           and t.id = kt.topic_id
           and u.id = $2
       )"
    {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [topic_id, user_id])
    rows
  end

  def suggest_prereqs(substring, subject_id) do
    query = "select id, name from topics where subject_id = $1 and name like $2"
    pattern = "%" <> substring <> "%"
    {:ok, %Postgrex.Result{:rows => rows}} = SQL.query(Repo, query, [subject_id, pattern])
    Enum.map(rows, fn [topic_id, name] -> {name, topic_id} end) |> Map.new()
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
end
