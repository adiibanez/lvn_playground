defmodule SensorsStateAgent do
  alias MyApp.SensorArrangement
  use Agent
  require Logger

  def start_link(params) do
    configuration = get_default_config()

    Logger.debug("SensorsStateAgent start_link2: #{inspect(configuration)}")
    # IO.inspect(via_tuple(configuration.sensor_id), label: "via tuple for sensor")
    Agent.start_link(
      fn ->
        create_state_from_config(configuration)
      end,
      name: :sensors_state_agent
    )
  end

  def get_default_config() do
    %{
      :number_of_sensors => 10,
      :x_min => -0.5,
      :x_max => 0.5,
      :y_min => -0.3,
      :y_max => 0.2,
      :z_amplitude => 0.05,
      :z_offset => 0.0,
      :size => 0.03
    }
  end

  def get_colors() do
    Agent.get(:sensors_state_agent, fn state ->
      get_in(state, [:colors]) |> dbg()
    end)
  end

  def put_sensor(sensor_id, payload) do
    Agent.update(:sensors_state_agent, fn state ->
      update_in(state, [:sensors, sensor_id], fn sensor ->
        Logger.debug("Updating sensor: Old: #{inspect(sensor)} New: #{inspect(payload)}")
        payload
      end)
    end)
  end

  def put_attribute(sensor_id, attribute, payload) do
    Agent.update(:sensors_state_agent, fn state ->
      update_in(state, [:sensors, sensor_id, attribute], fn attribute ->
        Logger.debug("Updating attribute: Old: #{inspect(attribute)} New: #{inspect(payload)}")
        payload
      end)
    end)
  end

  def get_attribute(sensor_id, attribute) do
    Agent.get(:sensors_state_agent, fn state ->
      get_in(state, [:sensors, sensor_id, attribute])
    end)
  end

  def get_sensor(sensor_id) do
    Agent.get(:sensors_state_agent, fn state ->
      get_in(state, [:sensors, sensor_id])
    end)
  end

  def get_state() do
    # Agent.get(:sensors_state_agent, & &1)

    Agent.get(:sensors_state_agent, fn state ->
      get_in(state, [:sensors])
    end)
  end

  def reset(config) do
    Logger.debug("Agent reset config #{inspect(config)}")

    Agent.update(:sensors_state_agent, fn state ->
      create_state_from_config(config)
    end)
  end

  # defp via_tuple(sensor_id) do
  #   # Sensocto.RegistryUtils.via_dynamic_registry(Sensocto.SimpleAttributeRegistry, sensor_id)

  #   {:via, Registry, {Sensor, sensor_id}}
  # end

  defp create_state_from_config(config) do
    %{
      :sensors => SensorArrangement.get_initial_sensors(config),
      :colors => SensorArrangement.get_colors(config[:number_of_sensors])
    }
  end
end

defmodule MyApp.SensorArrangement do
  require Logger

  @colors [
    "red",
    "green",
    "blue",
    "orange",
    "yellow",
    "pink",
    "purple",
    "teal",
    "indigo",
    "brown",
    "gray"
    # "gray2",
    # "gray3",
    # "gray4",
    # "gray5",
    # "gray6",
    # "label"
    # "secondarylabel",
    # "tertiarylabel",
    # "quaternarylabel",
    # "fill",
    # "secondarysystemfill",
    # "tertiarysystemfill",
    # "quaternarysystemfill",
    # "placeholdertext"
  ]

  def get_colors_(number \\ 100) do
    generate_rgb_colors(number)
  end

  def get_colors(number \\ 100) do
    @colors
  end

  @doc """
  Arranges sensors in an elliptic (rainbow) shape with configurable
  min/max X and Y positions, and the Z-axis moving forth and back (once).

  Configuration parameters:
    * number_of_sensors: The number of sensors to arrange.
    * x_min: Minimum X position. Defaults to -0.3.
    * x_max: Maximum X position. Defaults to 0.3.
    * y_min: Minimum Y position. Defaults to -0.1.
    * y_max: Maximum Y position. Defaults to 0.2.
    * z_amplitude: Amplitude of the Z-axis movement. Defaults to 0.25.
    * z_offset: Offsets all sensors along the z-axis. Defaults to 0.0.
  """

  def get_initial_sensors(config) do
    number_of_sensors = config[:number_of_sensors]
    x_min = config[:x_min] || -0.3
    x_max = config[:x_max] || 0.3
    y_min = config[:y_min] || -0.1
    y_max = config[:y_max] || 0.2
    # Default Z amplitude
    z_amplitude = config[:z_amplitude] || 0.25
    z_offset = config[:z_offset] || 0.0

    size = config[:size] || 0.03

    Enum.map(1..number_of_sensors, fn sensor_num ->
      # Normalize the sensor number to a value between 0 and 1
      t = (sensor_num - 1) / (number_of_sensors - 1)

      # X: Map 't' from 0..1 to x_min..x_max
      sensor_x = x_min + t * (x_max - x_min)

      # Y: Create an elliptic arc within y_min..y_max
      # Center the arc vertically
      y_center = (y_min + y_max) / 2
      # Amplitude of the arc (half the height)
      y_amplitude = (y_max - y_min) / 2
      # Full semi-circle
      angle = t * :math.pi()
      # Position on the semi-circle
      sensor_y = y_center + y_amplitude * :math.sin(angle)

      # Z: Forth and back, then stop
      sensor_z = z_offset + z_amplitude * :math.sin(:math.pi() * t)

      Logger.debug("Sensor #{sensor_num}: x=#{sensor_x}, y=#{sensor_y}, z=#{sensor_z}")

      sensor_id = "Connector#{sensor_num}"

      %{
        sensor_id => %{
          :size => size,
          :translation => %{
            :x => get_rounded_float(sensor_x),
            :y => get_rounded_float(sensor_y),
            :z => get_rounded_float(sensor_z)
          },
          :rotation => %{
            :x => 0,
            :y => 0,
            :z => 0
          },
          :color => Enum.random(@colors),
          :attributes => %{
            "heartrate" => %{
              :timestamp => "2021-03-08T14:39:36Z"
            }
          }
        }
      }
    end)
    |> Enum.reduce(&Map.merge(&1, &2))
  end

  def generate_rgb_colors(count) do
    Enum.map(1..count, fn _ ->
      r = :rand.uniform()
      g = :rand.uniform()
      b = :rand.uniform()
      [r, g, b]
    end)
  end

  defp get_rounded_float(float_value) do
    round(float_value * 1000.0) / 1000.0
  end
end
