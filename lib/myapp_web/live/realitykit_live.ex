defmodule MyappWeb.RealitykitLive do
  alias Phoenix.PubSub
  use MyappWeb, :live_view
  use MyappNative, :live_view
  require Logger

  @colors ["red", "green", "blue", "black", "yellow", "orange"]

  def handle_params(_params, uri, socket) do
    {:noreply, socket}
  end

  def mount(_params, _session, socket) do
    PubSub.subscribe(Myapp.PubSub, "sensors")

    {:ok,
     socket
     |> assign(:sensors, SensorsStateAgent.get_state())
     |> assign(:colors, SensorsStateAgent.get_colors())
     |> assign(:config, %{
       :number_of_sensors => 10,
       :x_min => -0.3,
       :x_max => 0.3,
       :y_min => -0.1,
       :y_max => 0.5,
       :z_compression => 0.1,
       :z_offset => 0.0
     })}
  end

  def handle_event(
        "update_sensor",
        %{
          "sensor_id" => sensor_id,
          "color" => color,
          "size" => size,
          "translation.x" => translation_x,
          "translation.y" => translation_y,
          "translation.z" => translation_z,
          "rotation.x" => rotation_x,
          "rotation.y" => rotation_y,
          "rotation.z" => rotation_z
        } = params,
        socket
      ) do
    SensorsStateAgent.put_attribute(sensor_id, :color, color)
    SensorsStateAgent.put_attribute(sensor_id, :size, get_rounded_float(size))

    SensorsStateAgent.put_attribute(sensor_id, :translation, %{
      x: get_rounded_float(translation_x),
      y: get_rounded_float(translation_y),
      z: get_rounded_float(translation_z)
    })

    SensorsStateAgent.put_attribute(sensor_id, :rotation, %{
      x: get_rounded_float(rotation_x),
      y: get_rounded_float(rotation_y),
      z: get_rounded_float(rotation_z)
    })

    PubSub.broadcast(Myapp.PubSub, "sensors", {
      :update_sensor,
      %{
        :sensor_id => sensor_id
      }
    })

    {:noreply, socket |> assign(:sensors, SensorsStateAgent.get_state())}
  end

  defp get_rounded_float(str_value) do
    {float_value, _} = Float.parse(str_value)
    rounded_value = round(float_value * 1000.0) / 1000.0
  end

  def handle_event(
        "config_sensors",
        %{
          "config.number_of_sensors" => number_of_sensors,
          "config.x_max" => x_max,
          "config.x_min" => x_min,
          "config.y_max" => y_max,
          "config.y_min" => y_min,
          "config.z_compression" => z_compression,
          "config.z_offset" => z_offset
        } = params,
        socket
      ) do
    Logger.debug("config_sensors #{inspect(params)}")

    {number_int, _} = Integer.parse(number_of_sensors)

    new_config = %{
      :number_of_sensors => number_int,
      :x_min => get_rounded_float(x_min),
      :x_max => get_rounded_float(x_max),
      :y_min => get_rounded_float(y_min),
      :y_max => get_rounded_float(y_max),
      :z_offset => get_rounded_float(z_offset),
      :z_compression => get_rounded_float(z_compression)
    }

    SensorsStateAgent.reset(new_config)

    PubSub.broadcast(Myapp.PubSub, "sensors", :config_sensors)

    {:noreply,
     socket |> assign(:sensors, SensorsStateAgent.get_state()) |> assign(:config, new_config)}
  end

  def handle_event("test_event_realitykit", params, socket) do
    Logger.debug("test_event_realitykit #{inspect(params)}")
    {:noreply, socket}
  end

  def handle_event("test-event2", params, socket) do
    Logger.debug("Gesture #{inspect(params)}")
    {:noreply, socket}
  end

  def handle_event("reset_sensors", %{"number_of_sensors" => number_of_sensors} = params, socket) do
    {number_of_sensors_int, _} = Integer.parse(number_of_sensors)
    SensorsStateAgent.reset(%{:number_of_sensors => number_of_sensors_int})
    {:noreply, socket}
  end

  def handle_info(
        {:update_sensor, %{:sensor_id => sensor_id}} =
          params,
        socket
      ) do
    Logger.debug("Received broadcast: PID: #{inspect(self())} #{inspect(params)}")

    {:noreply,
     socket
     |> assign(:sensors, SensorsStateAgent.get_state())}
  end

  def handle_info(
        :config_sensors,
        socket
      ) do
    Logger.debug("Received broadcast: PID: #{inspect(self())} :config_sensors")

    {:noreply,
     socket
     |> assign(:sensors, SensorsStateAgent.get_state())}
  end

  def render(assigns) do
    Logger.debug("Live pid: #{inspect(self())}")

    ~H"""
    <h2>Realitykit html view</h2>

    <form phx-submit="config_sensors">
      <ul>
        <li>
          <input type="submit" value="Config sensors" />
          <label for="config.number_of_sensors">config.number_of_sensors</label>
          <input
            name="config.number_of_sensors"
            type="range"
            value={@config.number_of_sensors}
            min="1"
            max="50"
            step="1"
            phx-value={@config.number_of_sensors}
          /> {@config.number_of_sensors}
        </li>
        <li>
          <label for="config.x_min">config.x_min</label>
          <input
            name="config.x_min"
            type="range"
            value={@config.x_min}
            min="-1"
            max="1"
            step="0.01"
            phx-value={@config.x_min}
          /> {@config.x_min}

          <label for="config.x_max">config.x_max</label>
          <input
            name="config.x_max"
            type="range"
            value={@config.x_max}
            min="-1"
            max="1"
            step="0.01"
            phx-value={@config.x_max}
          /> {@config.x_max}
        </li>
        <li>
          <label for="config.y_min">config.y_min</label>
          <input
            name="config.y_min"
            type="range"
            value={@config.y_min}
            min="-1"
            max="1"
            step="0.01"
            phx-value={@config.y_min}
          /> {@config.y_min}

          <label for="config.y_max">config.y_max</label>
          <input
            name="config.y_max"
            type="range"
            value={@config.y_max}
            min="-1"
            max="1"
            step="0.01"
            phx-value={@config.y_max}
          /> {@config.y_max}
        </li>
        <li>
          <label for="config.z_compression">config.z_compression</label>
          <input
            name="config.z_compression"
            type="range"
            value={@config.z_compression}
            min="-1"
            max="1"
            step="0.01"
            phx-value={@config.z_compression}
          /> {@config.z_compression}

          <label for="config.z_offset">config.z_offset</label>
          <input
            name="config.z_offset"
            type="range"
            value={@config.z_offset}
            min="-1"
            max="1"
            step="0.01"
            phx-value={@config.z_offset}
          /> {@config.z_offset}
        </li>
      </ul>
    </form>

    <div :for={{sensor_id, sensor} <- @sensors} id={sensor_id}>
      <strong>Sensor: {sensor_id}</strong>

      <form
        id={"form-#{sensor_id}"}
        phx-debounce="100"
        phx-change="update_sensor"
        phx-value-sensor_id={sensor_id}
      >
        <ul>
          <li>
            <label style={"background-color:#{sensor.color}"} for="color">Color</label>

            {inspect(@colors)}

            <select name="color">
              <option :for={color <- @colors} value={color} selected={sensor.color == color}>
                {color}
              </option>
            </select>
          </li>
          <li>
            <label for="size">Size</label>
            <input
              name="size"
              type="range"
              value={sensor.size}
              min="0.01"
              max="0.5"
              step="0.01"
              phx-value={sensor.size}
            /> {sensor.size}
          </li>
          <li>
            <div>
              <label for="translation.x">Translation X</label>
              <input
                name="translation.x"
                type="range"
                value={sensor.translation.x}
                min="-0.5"
                max="0.5"
                step="0.01"
                phx-value-axis="translation.x"
                phx-value={sensor.translation.x}
              /> {sensor.translation.x}
            </div>
            <div>
              <label for="rotation.x">Rotation X</label>
              <input
                name="rotation.x"
                type="range"
                value={sensor.rotation.x}
                min="0.0"
                max="1"
                step="0.01"
                phx-value-axis="rotation.x"
                phx-value={sensor.rotation.x}
              /> {sensor.rotation.x}
            </div>
          </li>

          <li>
            <div>
              <label for="translation.y">Translation Y</label>
              <input
                name="translation.y"
                type="range"
                value={sensor.translation.y}
                min="-0.5"
                max="0.5"
                step="0.01"
                phx-value-axis="translation.y"
                phx-value={sensor.translation.y}
              /> {sensor.translation.y}
            </div>
            <div>
              <label for="rotation.y">Rotation Y</label>
              <input
                name="rotation.y"
                type="range"
                value={sensor.rotation.y}
                min="0.0"
                max="1"
                step="0.01"
                phx-value-axis="rotation.y"
                phx-value={sensor.rotation.y}
              /> {sensor.rotation.y}
            </div>
          </li>

          <li>
            <div>
              <label for="translation.z">Translation Z</label>
              <input
                name="translation.z"
                type="range"
                value={sensor.translation.z}
                min="-0.5"
                max="0.5"
                step="0.01"
                phx-value-axis="translation.z"
                phx-value={sensor.translation.z}
              /> {sensor.translation.z}
            </div>
            <div>
              <label for="rotation.z">Rotation Z</label>
              <input
                name="rotation.z"
                type="range"
                value={sensor.rotation.z}
                min="0.0"
                max="1"
                step="0.01"
                phx-value-axis="rotation.z"
                phx-value={sensor.rotation.z}
              /> {sensor.rotation.z}
            </div>
          </li>
        </ul>
      </form>
    </div>
    """
  end
end
