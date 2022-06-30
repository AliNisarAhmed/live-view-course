defmodule LiveViewStudioWeb.GitReposLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.GitRepos

  def mount(_params, _session, socket) do
    socket = default_assigns(socket)

    {:ok, socket, temporary_assigns: [repos: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Trending Git Repos</h1>
    <div id="repos">

      <form phx-change="filter">
        <div class="filters">
          <select name="language" id="">
            <%= options_for_select(language_options(), @language) %>
          </select>

          <select name="license" id="">
            <%= options_for_select(license_options(), @license) %>
          </select>

          <a href="#" phx-click="clear-all-filters">Clear All</a>
        </div>
      </form>

      <div class="repos">
        <ul>
          <%= for repo <- @repos do %>
            <li>
              <div class="first-line">
                <div class="group">
                  <img src="images/terminal.svg">
                  <a href={repo.owner_url}>
                    <%= repo.owner_login %>
                  </a>
                  /
                  <a href={repo.url}>
                    <%= repo.name %>
                  </a>
                </div>
                <button>
                  <img src="images/star.svg">
                  Star
                </button>
              </div>
              <div class="second-line">
                <div class="group">
                  <span class={"language #{repo.language}"}>
                    <%= repo.language %>
                  </span>
                  <span class="license">
                    <%= repo.license %>
                  </span>
                  <%= if repo.fork do %>
                    <img src="images/fork.svg">
                  <% end %>
                </div>
                <div class="stars">
                  <%= repo.stars %> stars
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("clear-all-filters", _, socket) do
    socket = default_assigns(socket)
    {:noreply, socket}
  end

  def handle_event("filter", %{"language" => language, "license" => license}, socket) do
    params = [language: language, license: license]
    repos = GitRepos.list_git_repos(params)

    socket =
      socket
      |> assign(params ++ [repos: repos])

    {:noreply, socket}
  end

  defp default_assigns(socket) do
    socket
    |> assign(
      repos: GitRepos.list_git_repos(),
      language: "",
      license: ""
    )
  end

  defp license_options do
    [
      "All Licenses": "",
      Apache: "apache",
      MIT: "mit",
      BSDL: "bsdl"
    ]
  end

  defp language_options do
    [
      "All Langugaes": "",
      "Elixir": "elixir",
      Ruby: "ruby",
      Javascript: "javascript"
    ]
  end
end
