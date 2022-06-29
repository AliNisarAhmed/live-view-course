defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    id = String.to_integer(id)

    server = Servers.get_server!(id)

    socket =
      assign(socket,
        selected_server: server,
        page_title: "What's up #{server.name}?"
      )

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    if socket.assigns.live_action == :new do
      changeset = Servers.change_server(%Server{})

      socket =
        assign(socket,
          selected_server: nil,
          changeset: changeset
        )

      {:noreply, socket}
    else
      socket = assign(socket, selected_server: hd(socket.assigns.servers))
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div>
        <%= live_patch "New Server",
              to: Routes.servers_path(@socket, :new),
              class: "button"
        %>
      </div>
      <div class="sidebar">
        <nav>
          <%= for server <- @servers do %>
            <div>
              <%= live_patch link_body(server),
                  to: Routes.live_path(
                      @socket,
                      __MODULE__,
                      id: server.id
                  ),
                  class: if server == @selected_server, do: "active"
              %>
            </div>
          <% end %>
        </nav>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <.form
              let={f}
              for={@changeset}
              url="#"
              phx-submit="save"
            >
              <div class="field">
                Name:
                  <%= text_input(f, :name, placeholder: "Name", autocomplete: "off") %>
                  <%= error_tag f, :name %>
              </div>
              <div class="field">
                Framework:
                  <%= text_input(f, :framework, placeholder: "Framework", autocomplete: "off") %>
                  <%= error_tag f, :framework %>
              </div>
              <div class="field">
                Size (MB):
                  <%= text_input(f, :size, placeholder: "Size", autocomplete: "off") %>
                  <%= error_tag f, :size %>
              </div>
              <div class="field">
                Git Repo:
                  <%= text_input(f, :git_repo, placeholder: "Git Repo", autocomplete: "off") %>
                  <%= error_tag f, :git_repo %>
              </div>

              <%= submit "Submit", phx_disable_with: "Saving..." %>
              <%= live_patch "Cancel",
                    to: Routes.live_path(@socket, __MODULE__),
                    class: "cancel" %>
            </.form>
          <% else %>
            <div class="card">
              <div class="header">
                <h2><%= @selected_server.name %></h2>
                <span class={@selected_server.status}>
                  <%= @selected_server.status %>
                </span>
              </div>
              <div class="body">
                <div class="row">
                  <div class="deploys">
                    <img src="/images/deploy.svg">
                    <span>
                      <%= @selected_server.deploy_count %> deploys
                    </span>
                  </div>
                  <span>
                    <%= @selected_server.size %> MB
                  </span>
                  <span>
                    <%= @selected_server.framework %>
                  </span>
                </div>
                <h3>Git Repo</h3>
                <div class="repo">
                  <%= @selected_server.git_repo %>
                </div>
                <h3>Last Commit</h3>
                <div class="commit">
                  <%= @selected_server.last_commit_id %>
                </div>
                <blockquote>
                  <%= @selected_server.last_commit_message %>
                </blockquote>
              </div>
            </div>
          <% end %>

        </div>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"server" => params}, socket) do
    case Servers.create_server(params) do
      {:ok, server} ->
        socket = update(socket, :servers, fn svs -> [server | svs] end)

        socket =
          push_patch(socket,
            to:
              Routes.live_path(
                socket,
                __MODULE__,
                id: server.id
              )
          )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  defp link_body(server) do
    assigns = %{name: server.name, status: server.status}

    ~H"""
    <span class={"status #{@status}"}></span>
    <img src="/images/server.svg">
    <%= @name %>
    """
  end
end
