defmodule Web.GitHubWebhookControllerTest do
  use Web.ConnCase

  alias Data.{Opportunities, Projects}

  defp webhook_body_for_project(project) do
    %{
      "action": "opened",
      "issue": %{
        "html_url": "https://github.com/repos/elixirschool/extracurricular/issues/2",
        "title": "This is a test",
        "user": %{
          "login": "doomspork",
        },
        "labels": [
          %{
            "name": "Kind:Starter",
            "color": "fc2929",
            "default": true
          }
        ],
        "state": "open",
        "closed_at": nil
      },
      "repository": %{
        "name": project.name,
        "html_url": project.url,
      },
      "sender": %{
        "login": "doomspork"
      }
    }
  end

  describe "with existing project" do
    setup do
      {:ok, project} = Projects.insert(%{name: "public-repo", url: "https://github.com/repos/elixirschool/extracurricular"})
      [project: project]
    end

    test "POST /webhooks/github creates opportunity", %{conn: conn, project: project} do
      body =
        project
        |> webhook_body_for_project
        |> Poison.encode!

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/webhooks/github?api_token=#{project.api_token}", body)

      json_response(conn, 201)

      opportunities = Opportunities.all()
      assert length(opportunities.entries) == 1
    end
  end

  describe "with no existing project" do
    setup do
      project =
        %{
          api_token: "a-random-token",
          name: "this-project-should-never-be-in-the-db",
          url: "https://github.com/repos/elixirschool/extracurricular"
        }

      [project: project]
    end

    test "POST /webhooks/github does not create opportunity", %{conn: conn, project: project} do
      body =
        project
        |> webhook_body_for_project
        |> Poison.encode!

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/webhooks/github", body)

      json_response(conn, 201)

      opportunities = Opportunities.all()
      assert length(opportunities.entries) == 0
    end
  end
end
