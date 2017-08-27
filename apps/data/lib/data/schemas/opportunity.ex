defmodule Data.Opportunity do
  @moduledoc """
  The schema representation of our `opportunities` table
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Data.Project

  @acceptable_levels Application.get_env(:data, :levels)
  @acceptable_types Application.get_env(:data, :types)

  schema "opportunities" do
    field :closed_at, :utc_datetime # when it was closed/completed
    field :level, :string # starter, intermediate, advanced
    field :title, :string
    field :type, :string # bug, discussion, enchancement, feature
    field :url, :string

    belongs_to :project, Project

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:closed_at, :level, :project_id, :title, :type, :url])
    |> validate_required([:level, :title, :url])
    |> validate_inclusion(:level, @acceptable_levels)
    |> validate_inclusion(:type, @acceptable_types)
    |> assoc_constraint(:project)
  end
end
