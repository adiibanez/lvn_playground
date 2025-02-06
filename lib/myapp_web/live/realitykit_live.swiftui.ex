defmodule MyappWeb.RealitykitLive.SwiftUI do
  use MyappNative, [:render_component, format: :swiftui]
  require Logger
  alias MyAppWeb.Live.Components.Swiftui.RealityKit.SensorComponent

  def mount(_params, _session, socket) do
    Logger.debug("Mount SWIFT pid: #{inspect(self())}")
    # PubSub.subscribe(Myapp.PubSub, "sensors")
  end

  def render(assigns, interface) do
    Logger.debug("SWIFT render pid: #{inspect(self())} #{inspect(interface)}")

    # Enum.all?(assigns[:sensors], fn {sensor_id, sensor} ->
    #   Logger.debug(
    #     "SWIFT Sensor: #{sensor_id} #{inspect(sensor.translation)} #{is_float(sensor.translation.x)} #{is_integer(sensor.translation.x)}"
    #   )
    # end)

    #  <SimpleMaterial
    #   template="materials"
    #   color="system-red"
    # />

    # https://medium.com/better-programming/introduction-to-realitykit-on-ios-entities-gestures-and-ray-casting-8f6633c11877

    ~LVN"""

    <Text id={"realitykit_text_#{sensor_id}"} :for={{sensor_id, sensor} <- @sensors}>Hello {sensor_id}!</Text>

    <RealityView id="reality_view_2" phx-click="test_event_realityview" phx-change="test_event_realityview" attachments={["test"]}>

    <.live_component  module={SensorComponent} :for={{sensor_id, sensor} <- @sensors}
      id={sensor_id}
      sensor_id={sensor_id}
      sensor={sensor}>
    </.live_component>

    </RealityView>
    """
  end
end
