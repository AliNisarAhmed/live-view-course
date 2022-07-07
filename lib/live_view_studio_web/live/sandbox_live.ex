defmodule LiveViewStudioWeb.SandboxLive do
  use LiveViewStudioWeb, :live_view

  import LiveViewStudioWeb.QuoteComponent
  alias LiveViewStudioWeb.SandboxCalculatorComponent
  alias LiveViewStudio.SandboxCalculator

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        weight: nil,
        price: nil
      )

    {:ok, socket}
  end

  def handle_info({:totals, weight, price}, socket) do
    socket = assign(socket, weight: weight, price: price)
    {:noreply, socket}
  end
end
