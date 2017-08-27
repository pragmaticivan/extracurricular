defmodule Web.GitHubWebhookController do
  @moduledoc """
  GitHub Webhook controller is responsible for all incoming requests from GitHub
  """
  use Web, :controller
  require Logger

  alias Data.{Opportunities, Projects}

  plug :authorize

  def create(conn, %{"action" => action, "issue" => issue} = issue_event)
    when is_map(issue) and action in ["closed", "labeled", "opened", "reopened"] do

    process_issue(issue_event)

    thank_you(conn)
  end

  def create(conn, _) do
    thank_you(conn)
  end

  def process_issue(%{"issue" => issue, "repository" => %{"html_url" => url, "name" => name}}) do
    case Projects.get(%{url: url}) do
      nil -> Logger.info("Received issue payload for untracked project: #{name} #{url}")
      project ->
        issue
        |> attributes(project)
        |> Opportunities.insert_or_update
    end
  end

  defp attributes(issue, %{id: project_id}) do
    %{
      closed_at: issue["closed_at"],
      level:  label_mapping(issue, level_mapping()),
      project_id: project_id,
      title: issue["title"],
      type:  label_mapping(issue, type_mapping()),
      url: issue["html_url"]
    }
  end

  defp authorize(%{params: %{"api_token" => api_token}} = conn, _opts) do
    case Projects.get(%{api_token: api_token}) do
      nil -> thank_you(conn)
      _match -> conn
    end
  end

  defp authorize(conn, _opts), do: thank_you(conn)

  defp label_mapping(%{"labels" => []}, _mapping), do: nil
  defp label_mapping(%{"labels" => labels}, mapping) do
    labels = Enum.map(labels, fn (label) -> label |> Map.get("name") |> String.downcase end)
    mapping = Enum.find(mapping, fn {_, mappings} -> length(mappings -- (mappings -- labels)) != 0 end)

    case mapping do
      {label, _} -> label
      _ -> nil
    end
  end

  defp level_mapping, do: Application.get_env(:web, :level_label_mapping)

  defp thank_you(conn) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> send_resp(201, Poison.encode!(%{msg: "thank you"}))
    |> halt
  end

  defp type_mapping, do: Application.get_env(:web, :type_label_mapping)
end
