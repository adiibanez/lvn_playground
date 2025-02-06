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
    <ModelEntity  id={"model_entity_#{@sensor_id}"}
      transform:translation={[@sensor.translation.x, @sensor.translation.y, @sensor.translation.z]}
       transform:rotation={[@sensor.rotation.x, @sensor.rotation.y, @sensor.rotation.z, @sensor.rotation.angle]}
      generateCollisionShapes="recursive"
      phx-change="model_change"
      phx-click="model_tapped"
      phx-value-sensor_id={@sensor_id}>
    <Box id={"box_#{@sensor_id}"}
      template="mesh"
      size={@sensor.size}
      phx-change="box_change"
      phx-click="box_tapped"
      phx-value-sensor_id={@sensor_id}>
    ></Box>

    <ViewAttachmentEntity  id={"view_attachment_#{@sensor_id}"} attachment={"realitykit_text_#{@sensor_id}"}
      text={@sensor_id}
      font="system-font-bold"
      fontSize={20}
      color={"system-#{@sensor.color}"}
     />

    <PhysicallyBasedMaterial
     id={"physics_base_material_#{@sensor_id}"}
    template="materials"
    baseColor={"system-#{@sensor.color}"}
    metallic={0.9}
    roughness={0.1}
    />

    <Group template="components">
      <CollisionComponent  id={"collision_component_#{@sensor_id}"} phx-click="test_collision_component" phx-change="collision_change"/>
      <PhysicsBodyComponent mass="0.5"  id={"physics_body_component_#{@sensor_id}"} phx-click="test_physics_body_component" phx-change="test_physics_body_component"/>
      <OpacityComponent opacity={0.8}  id={"opacity_component_#{@sensor_id}"} />
      <GroundingShadowComponent  id={"grouping_shadow_component_#{@sensor_id}"} castsShadow />
      <AnchoringComponent id={"anchor_#{@sensor_id}"} target="plane" alignment="horizontal" classification="table" />
    </Group>
    </ModelEntity>
    """
  end
end
