defmodule MyAppWeb.Live.Components.Swiftui.RealityKit.SensorComponent do
  use MyappNative, [:render_component, format: :swiftui]
  use Phoenix.LiveComponent

  use LiveViewNative.Component,
    format: :swiftui,
    as: :render

  require Logger

  def render(assigns, %{"target" => "watchos"}) do
    ~LVN"""
    <Text>Hello, from WatchOS!</Text>
    """
  end

  def render(assigns, _interface) do
    ~LVN"""
    <ModelEntity id={@sensor_id}
      transform:translation={[@sensor.translation.x, @sensor.translation.y, @sensor.translation.z]}
       transform:rotation={[@sensor.rotation.x, @sensor.rotation.y, @sensor.rotation.z, @sensor.rotation.angle]}
      generateCollisionShapes="recursive"
      phx-change="model_change"
      phx-click="model_tapped"
      phx-value-sensor_id={@sensor_id}>
    <Box
      template="mesh"
      size={@sensor.size}
    />

    <ViewAttachmentEntity attachment="test">

    </ViewAttachmentEntity>

    <PhysicallyBasedMaterial
    template="materials"
    baseColor={"system-#{@sensor.color}"}
    metallic={0.9}
    roughness={0.1}
    />

    <Group template="components">
      <CollisionComponent phx-click="test_collision_component" phx-change="collision_change"/>
      <PhysicsBodyComponent mass="0.5" phx-click="test_physics_body_component" phx-change="test_physics_body_component"/>
      <OpacityComponent opacity={0.8} />
      <GroundingShadowComponent castsShadow />
      <AnchoringComponent
        trackingMode="continuous"
        target="plane"
        chirality="right"
        handLocation="palm"
        alignment="horizontal"
        classification="table"
        minimumBounds:x={1}
        minimumBounds:y={1}
      />
    </Group>
    </ModelEntity>
    """
  end
end
