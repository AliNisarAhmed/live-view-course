defmodule LiveViewStudioWeb.PageLive do
  use LiveViewStudioWeb, :live_view

  @pages [
    {LiveViewStudioWeb.AutocompleteLive, "autocomplete"},
    {LiveViewStudioWeb.FilterLive, "filter"},
    {LiveViewStudioWeb.FlightsLive, "flights"},
    {LiveViewStudioWeb.GitReposLive, "gitrepos"},
    {LiveViewStudioWeb.LicenseLive, "license"},
    {LiveViewStudioWeb.LightLive, "light"},
    {LiveViewStudioWeb.SalesDashboardLive, "sales_dashboard"},
    {LiveViewStudioWeb.SearchLive, "search"},
    {LiveViewStudioWeb.ServersLive, "servers"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, pages: @pages)}
  end
end
