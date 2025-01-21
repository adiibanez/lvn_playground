defmodule MyappWeb.ChartsLive do
  use MyappWeb, :live_view
  use MyappNative, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:data, (for _ <- 1..5, do: :rand.uniform()))}
  end

  def render(assigns) do
    ~H""
  end

  def handle_event("add-item", _params, %{ assigns: %{ data: data } } = socket) do
    {:noreply, assign(socket, :data, data ++ [:rand.uniform()])}
  end
end
