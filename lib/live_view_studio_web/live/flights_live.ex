defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        loading: false,
        flight_number: "",
        flights: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="search">

      <form phx-submit="search-flights">
        <input type="text" name="flight_number" value={@flight_number}
               placeholder="Search Flights" autofocus autocomplete="off" readonly={@loading}/>
        <button type="submit">
          <img src="images/search.svg" alt="">
        </button>
      </form>

      <%= if @loading do %>
        <div class="loader">Loading...</div>
      <% end %>

      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %> to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= format_flight_time(flight.departure_time) %>
                </div>
                <div class="arrives">
                  Arrives: <%= format_flight_time(flight.arrival_time) %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_info({:search_flights, flight_number}, socket) do
    case Flights.search_by_number(flight_number) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No flights matching \"#{flight_number}\"")
          |> assign(flights: [], loading: false)

        {:noreply, socket}

      flights ->
        socket =
          socket
          |> clear_flash()
          |> assign(flights: flights, loading: false)

        {:noreply, socket}
    end

    socket =
      socket
      |> assign(flights: Flights.search_by_number(flight_number), loading: false)

    {:noreply, socket}
  end

  def handle_event("search-flights", %{"flight_number" => flight_number}, socket) do
    send(self(), {:search_flights, flight_number})

    socket =
      socket
      |> assign(loading: true, flights: [], flight_number: flight_number)

    {:noreply, socket}
  end

  defp format_flight_time(time) do
    time
    |> Timex.format!("{D} {Mshort} {YYYY} at {h24}:{m} hours")
  end
end
