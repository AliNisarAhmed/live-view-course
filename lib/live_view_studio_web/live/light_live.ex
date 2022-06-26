defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: 3000)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <h1>Front Porch Light</h1>
      <div id="light">
        <div class="meter">
          <span style={"width: #{@brightness}%; background-color: #{temp_color(@temp)};%"}>
            <%= @brightness %>
          </span>
        </div>

        <form phx-change="update">
          <input type="range" min="1" max="100" name="brightness" value={@brightness} />
        </form>

        <button phx-click="off">
        <img src="images/light-off.svg" alt=" ">
        </button>

        <button phx-click="down">
          <img src="images/down.svg" alt="">
        </button>

        <button phx-click="up">
        <img src="images/up.svg" alt=" ">
        </button>

        <button phx-click="on">
          <img src="images/light-on.svg" alt="">
        </button>

        <button phx-click="light-me-up">
          ?
        </button>
      </div>
      <button phx-click="on">
        <img src="images/light-on.svg">
      </button>

      <form phx-change="change-temp">
        <%= for temp_option <- [3000, 4000, 5000] do %>
          <%= temp_radio_button(%{temp_option: temp_option, checked: temp_option == @temp}) %>
        <% end %>
      </form>
    """
  end

  def handle_event("update", %{"brightness" => brightness}, socket) do
    new_br = String.to_integer(brightness)
    socket = assign(socket, brightness: new_br)
    {:noreply, socket}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("light-me-up", _, socket) do
    socket = assign(socket, :brightness, Enum.random(0..100))
    {:noreply, socket}
  end

  def handle_event("change-temp", %{"temp" => temp}, socket) do
    socket =
      socket
      |> assign(:temp, String.to_integer(temp))

    {:noreply, socket}
  end

  defp temp_radio_button(assigns) do
    ~H"""
        <input
          type="radio"
          id={@temp_option}
          name="temp"
          value={@temp_option}
          checked={@checked}
        />
        <label for={@temp_option}><%= @temp_option %></label>
    """
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"
end
