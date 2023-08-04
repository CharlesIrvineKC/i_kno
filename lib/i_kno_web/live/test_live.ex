defmodule IKnoWeb.TestLive do
  use IKnoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-4 grid-flow-col gap-4">
      <div class="border rounded border-grey-900 p-3">01</div>
      <div class="border rounded border-grey-900 p-3">02</div>
      <div class="border rounded border-grey-900 p-3">03</div>
      <div class="border rounded border-grey-900 p-3">04</div>
      <div class="border rounded border-grey-900 p-3">05</div>
      <div class="border rounded border-grey-900 p-3">06</div>
      <div class="border rounded border-grey-900 p-3">07</div>
      <div class="border rounded border-grey-900 p-3">08</div>
      <div class="border rounded border-grey-900 p-3">01</div>
      <div class="border rounded border-grey-900 p-3">02</div>
      <div class="border rounded border-grey-900 p-3">03</div>
      <div class="border rounded border-grey-900 p-3">04</div>
      <div class="border rounded border-grey-900 p-3">05</div>
      <div class="border rounded border-grey-900 p-3">06</div>
      <div class="border rounded border-grey-900 p-3">07</div>
      <div class="border rounded border-grey-900 p-3">08</div>
      <div class="border rounded border-grey-900 p-3">01</div>
      <div class="border rounded border-grey-900 p-3">02</div>
      <div class="border rounded border-grey-900 p-3">03</div>
      <div class="border rounded border-grey-900 p-3">04</div>
      <div class="border rounded border-grey-900 p-3">05</div>
      <div class="border rounded border-grey-900 p-3">06</div>
      <div class="border rounded border-grey-900 p-3">07</div>
      <div class="border rounded border-grey-900 p-3">08</div>
      <div class="border rounded border-grey-900 p-3">01</div>
      <div class="border rounded border-grey-900 p-3">02</div>
      <div class="border rounded border-grey-900 p-3">03</div>
      <div class="border rounded border-grey-900 p-3">04</div>
      <div class="border rounded border-grey-900 p-3">05</div>
      <div class="border rounded border-grey-900 p-3">06</div>
      <div class="border rounded border-grey-900 p-3">07</div>
      <div class="border rounded border-grey-900 p-3">08</div>
    </div>
    """
  end
end
