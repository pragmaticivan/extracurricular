defmodule Web.OpportunitiesControllerTest do
  use Web.ConnCase

  alias Data.{Opportunities, Projects}

  test "GET /opportunities", %{conn: conn} do
    {:ok, %{id: project_id}} = Projects.insert(%{name: "Example Project", url: "example.com"})

    attributes = %{
      level: "starter",
      project_id: project_id,
      title: "Example Opportunity",
      url: "https://example.com/tracker/1"
    }

    Opportunities.insert(attributes)
    Opportunities.insert(%{attributes | title: "Another Opportunity"})

    conn = get conn, "/opportunities"
    assert html_response(conn, 200) =~ "Example Opportunity"
    assert html_response(conn, 200) =~ "Another Opportunity"
  end
end
