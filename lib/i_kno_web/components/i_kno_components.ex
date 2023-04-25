defmodule IKnoWeb.IKnoComponents do
  use Phoenix.Component

  attr(:input, :string, required: true)
  attr(:class, :string, default: "")

  def markdown(assigns) do
    ~H"""
    <div class="h-full flex flex-col justify-center items-center dark:text-white descendant:dark:text-white">
      <article class={[
        "prose dark:prose-invert prose-a:text-blue-600 descendant:dark:text-white",
        @class
      ]}>
        <%= Earmark.as_html!(@input, escape: false, inner_html: true, compact_output: false)
        |> Phoenix.HTML.raw() %>
      </article>
    </div>
    """
  end
end
