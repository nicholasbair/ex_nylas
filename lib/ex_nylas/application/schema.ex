defmodule ExNylas.Schema.Application do
  @moduledoc """
  A struct representing a Nylas application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.Schema.{
    ApplicationRedirect,
    Util
  }

  @primary_key false

  schema "application" do
    field :application_id, :string
    field :organization_id, :string
    field :region, :string
    field :created_at, :integer
    field :updated_at, :integer
    field :environment, Ecto.Enum, values: ~w(production staging)a
    field :v2_organization_id, :string

    embeds_one :branding, Branding, primary_key: false do
      field :name, :string
      field :icon_url, :string
      field :website_url, :string
      field :description, :string
    end

    embeds_one :hosted_authentication, HostedAuthentication, primary_key: false do
      field :background_image_url, :string
      field :alignment, Ecto.Enum, values: ~w(left center right)a
      field :color_primary, :string
      field :color_secondary, :string
      field :title, :string
      field :subtitle, :string
      field :background_color, :string
      field :spacing, :integer
    end

    embeds_many :callback_uris, ApplicationRedirect
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:application_id, :organization_id, :region, :created_at, :updated_at, :environment, :v2_organization_id])
    |> cast_embed(:branding, with: &Util.embedded_changeset/2)
    |> cast_embed(:hosted_authentication, with: &Util.embedded_changeset/2)
    |> cast_embed(:callback_uris)
    |> validate_required([:application_id, :organization_id, :region, :created_at, :updated_at, :environment])
  end
end
