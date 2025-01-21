defmodule MyappWeb.HomeLive do
  use MyappWeb, :live_view
  use MyappNative, :live_view

  def(render(assigns)) do
    ~H"""
    <h1>Welcome to LiveView!</h1>
    """
  end
end
