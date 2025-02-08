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
    <Group>

    <Attachment id={"attachment_#{@sensor_id}"} template="attachments">
              <HStack style="buttonStyle(.plain); padding(8); glassBackgroundEffect();">
              <Text>Hello {@sensor_id}</Text>
                <Button phx-click="rotate">
                  <Image systemName="arrow.2.circlepath.circle.fill" style="imageScale(.large); symbolRenderingMode(.hierarchical);" />
                </Button>
              </HStack>
              </Attachment>
              <ViewAttachmentEntity
              attachment={"attachment_#{@sensor_id}"}
              transform:translation={[@sensor.translation.x, @sensor.translation.y, @sensor.translation.z + 0.1]}
              transform:rotation={Nx.to_list(Quaternion.euler(-:math.pi / 2, 0, 0))}
              />

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
    </Group>
    """
  end
end
