[error] GenServer #PID<0.1020.0> terminating
** (Protocol.UndefinedError) protocol Enumerable not implemented for nil of type Atom
    (elixir 1.15.3) lib/enum.ex:1: Enumerable.impl_for!/1
    (elixir 1.15.3) lib/enum.ex:166: Enumerable.reduce/3
    (elixir 1.15.3) lib/enum.ex:4387: Enum.map/2
    (i_kno 0.1.0) lib/i_kno_web/live/components/answer_question.ex:24: anonymous fn/2 in IKnoWeb.AnswerQuestion.render_multiple_choice/1
    (i_kno 0.1.0) /Users/charlesirvine/src/i_kno/lib/i_kno_web/live/components/answer_question.ex:12: IKnoWeb.AnswerQuestion.render/1
    (elixir 1.15.3) lib/enum.ex:2510: Enum."-reduce/3-lists^foldl/2-0-"/3
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/diff.ex:384: Phoenix.LiveView.Diff.traverse/7
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/diff.ex:538: anonymous fn/4 in Phoenix.LiveView.Diff.traverse_dynamic/7
    (elixir 1.15.3) lib/enum.ex:2510: Enum."-reduce/3-lists^foldl/2-0-"/3
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/diff.ex:361: Phoenix.LiveView.Diff.traverse/7
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/diff.ex:711: Phoenix.LiveView.Diff.render_component/9
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/diff.ex:657: anonymous fn/5 in Phoenix.LiveView.Diff.render_pending_components/6
    (elixir 1.15.3) lib/enum.ex:2510: Enum."-reduce/3-lists^foldl/2-0-"/3
    (stdlib 5.0.2) maps.erl:416: :maps.fold_1/4
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/diff.ex:629: Phoenix.LiveView.Diff.render_pending_components/6
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/diff.ex:143: Phoenix.LiveView.Diff.render/3
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/channel.ex:833: Phoenix.LiveView.Channel.render_diff/3
    (phoenix_live_view 0.19.3) lib/phoenix_live_view/channel.ex:689: Phoenix.LiveView.Channel.handle_changed/4
Last message: %Phoenix.Socket.Message{topic: "lv:phx-F3NF09_ttNR44QDB", event: "event", payload: %{"event" => "submit-tf-answer", "type" => "form", "value" => "true%3F=false"}, ref: "8", join_ref: "4"}
