defmodule MyappWeb.RealitykitLive.SwiftUI do
  use MyappNative, [:render_component, format: :swiftui]
  require Logger

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

    ~LVN"""

    <.button phx-click="rotate">Rotate</.button>
    <Text id="test">Test</Text>

    <RealityView id="reality_view_2" phx-click="test_event_realityview" attachments={["test"]}>

    <ModelEntity id={sensor_id} :for={{sensor_id, sensor} <- @sensors}
      transform:translation={[sensor.translation.x, sensor.translation.y, sensor.translation.z]}
      transform:rotation={[1, 1, 1]}
      generateCollisionShapes="recursive"
      phx-click="model_tapped"
      phx-value-sensor_id={sensor_id}>
    <Box
      template="mesh"
      size={sensor.size}
    />

    <PhysicallyBasedMaterial
    template="materials"
    baseColor={"system-#{sensor.color}"}
    metallic={0.5}
    roughness={0.2}
    />

    <Group template="components">
    <CollisionComponent phx-click="test_collision_component"/>
    <PhysicsBodyComponent mass="0.5" phx-click="test_physics_body_component"/>
      <OpacityComponent opacity={0.8} />
      <GroundingShadowComponent castsShadow />
    <AnchoringComponent
    phx-click="test_anchoring_component"
        target="plane"
        trackingMode="once"
        alignment="horizontal"
        classification="table"
        minimumBounds:x={0.5}
        minimumBounds:y={0.5}
        minimumBounds:z={0.5}
      />


    </Group>


    </ModelEntity>


    </RealityView>
    """
  end
end
