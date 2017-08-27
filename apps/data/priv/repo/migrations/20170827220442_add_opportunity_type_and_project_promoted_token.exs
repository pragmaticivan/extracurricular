defmodule Data.Repo.Migrations.AddOpportunityTypeAndProjectPromotedToken do
  use Ecto.Migration

  def change do
    alter table(:opportunities) do
      add :type, :string, null: true
    end

    alter table(:projects) do
      add :promoted, :boolean, default: false
      add :api_token, :string, null: false
    end

    create unique_index(:projects, [:api_token])
  end
end
