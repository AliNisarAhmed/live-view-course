defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights
  alias LiveViewStudio.Airports

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        loading: false,
        flight_number: "",
        airport_code: "",
        flights: [],
        matches: []
      )

    {:ok, socket, temporary_assigns: [flights: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="search">

      <form phx-submit="search-flights">
        <input
          type="text"
          name="flight_number"
          value={@flight_number}
          placeholder="Search Flights"
          autofocus
          autocomplete="off"
          readonly={@loading}
        />
        <button type="submit">
          <img src="images/search.svg" alt="">
        </button>
      </form>

      <form phx-change="suggest-airport" phx-submit="airport-search">
        <input
          type="text"
          name="airport_code"
          value={@airport_code}
          placeholder="Search Airports"
          autocomplete="off"
          readonly={@loading}
          phx-debouce="1000"
          list="matches"
        />
        <button type="submit">
          <img src="images/search.svg" alt="">
        </button>
      </form>

      <datalist id="matches">
        <%= for match <- @matches do %>
          <option value={match}><%= match %></option>
        <% end %>
      </datalist>

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

  def handle_info({:run_airport_search, airport_code}, socket) do
    case Flights.search_by_airport(airport_code) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No flights matching \"#{airport_code}\"")
          |> assign(flights: [], loading: false)

        {:noreply, socket}

      flights ->
        socket =
          socket
          |> clear_flash()
          |> assign(flights: flights, loading: false)

        {:noreply, socket}
    end
  end

  def handle_event("search-flights", %{"flight_number" => flight_number}, socket) do
    send(self(), {:search_flights, flight_number})

    socket =
      socket
      |> assign(loading: true, flights: [], flight_number: flight_number)

    {:noreply, socket}
  end

  def handle_event("suggest-airport", %{"airport_code" => prefix}, socket) do
    socket = assign(socket, matches: Airports.suggest(prefix))
    {:noreply, socket}
  end

  def handle_event("airport-search", %{"airport_code" => airport_code}, socket) do
    send(self(), {:run_airport_search, airport_code})

    socket =
      socket
      |> assign(
        flights: [],
        loading: true,
        airport_code: "",
        flight_number: ""
      )

    {:noreply, socket}
  end

  defp format_flight_time(time) do
    time
    |> Timex.format!("{D} {Mshort} {YYYY} at {h24}:{m} hours")
  end
end
