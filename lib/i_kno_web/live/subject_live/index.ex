defmodule IKnoWeb.SubjectLive.Index do
  use IKnoWeb, :live_view

  alias IKno.Knowledge
  alias IKno.Knowledge.Subject

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :subjects, Knowledge.list_subjects())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Subject")
    |> assign(:subject, Knowledge.get_subject!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subject")
    |> assign(:subject, %Subject{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subjects")
    |> assign(:subject, nil)
  end

  @impl true
  def handle_info({IKnoWeb.SubjectLive.FormComponent, {:saved, subject}}, socket) do
    {:noreply, stream_insert(socket, :subjects, subject)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subject = Knowledge.get_subject!(id)
    {:ok, _} = Knowledge.delete_subject(subject)

    {:noreply, stream_delete(socket, :subjects, subject)}
  end
end
