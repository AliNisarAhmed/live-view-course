defmodule LiveViewStudioWeb.SalesDashboardLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Sales

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_stats()
      |> assign(:refresh, 1)
      |> assign(:last_updated_at, Timex.now())

    if connected?(socket) do
      schedule_refresh(socket)
    end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <h1>Sales Dashboard</h1>
      <div id="dashboard">
        <div class="stats">
          <div class="stat">
            <span class="value">
              <%= @new_orders %>
            </span>
            <span class="name">
              New Orders
            </span>
          </div>
          <div class="stat">
            <span class="value">
              $<%= @sales_amount %>
            </span>
            <span class="name">
              Sales Amount
            </span>
          </div>
          <div class="stat">
            <span class="value">
              <%= @satisfaction %>
            </span>
            <span class="name">
              Satisfaction
            </span>
          </div>


        </div>

          <div class="controls">
            <form phx-change="select-refresh">
              <label for="refresh">
                Refresh every:
              </label>
              <select name="refresh">
                <%= options_for_select(refresh_options(), @refresh) %>
              </select>
              <p>
                Last updated at <%= Timex.format!(@last_updated_at, "%H:%M:%S", :strftime) %>
              </p>
            </form>

            <button phx-click="refresh">
              <img src="images/refresh.svg" alt="">
                Refresh
              </button>
          </div>

      </div>
    """
  end

  def handle_event("refresh", _, socket) do
    {:noreply, assign_stats(socket)}
  end

  def handle_event("select-refresh", %{"refresh" => refresh}, socket) do
    socket =
      socket
      |> assign(:refresh, String.to_integer(refresh))
      |> assign(:last_updated_at, Timex.now())

    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    socket = assign_stats(socket)
    schedule_refresh(socket)
    {:noreply, socket}
  end

  defp assign_stats(socket) do
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.satisfaction()
    )
  end

  defp refresh_options do
    [{"1s", 1}, {"2s", 2}, {"3s", 3}, {"5s", 5}, {"10s", 10}]
  end

  defp schedule_refresh(socket) do
    Process.send_after(self(), :tick, socket.assigns.refresh * 1000)
  end
end
