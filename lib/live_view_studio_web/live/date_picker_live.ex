defmodule LiveViewStudioWeb.DatePickerLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, date: nil)}
  end

  def handle_event("date-selected", %{"date" => date}, socket) do
    socket = assign(socket, date: date)
    {:noreply, socket}
  end
end
