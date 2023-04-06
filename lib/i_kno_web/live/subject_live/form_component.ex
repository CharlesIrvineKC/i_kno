defmodule IKnoWeb.SubjectLive.FormComponent do
  use IKnoWeb, :live_component

  alias IKno.Knowledge

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage subject records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="subject-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:summary]} type="text" label="Summary" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Subject</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subject: subject} = assigns, socket) do
    changeset = Knowledge.change_subject(subject)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"subject" => subject_params}, socket) do
    changeset =
      socket.assigns.subject
      |> Knowledge.change_subject(subject_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subject" => subject_params}, socket) do
    save_subject(socket, socket.assigns.action, subject_params)
  end

  defp save_subject(socket, :edit, subject_params) do
    case Knowledge.update_subject(socket.assigns.subject, subject_params) do
      {:ok, subject} ->
        notify_parent({:saved, subject})

        {:noreply,
         socket
         |> put_flash(:info, "Subject updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subject(socket, :new, subject_params) do
    case Knowledge.create_subject(subject_params) do
      {:ok, subject} ->
        notify_parent({:saved, subject})

        {:noreply,
         socket
         |> put_flash(:info, "Subject created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
