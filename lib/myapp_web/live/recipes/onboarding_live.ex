defmodule MyappWeb.OnboardingLive do
  use MyappWeb, :live_view
  use MyappNative, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H""
  end
end
