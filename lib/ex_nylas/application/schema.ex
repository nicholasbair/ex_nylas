defmodule ExNylas.Application do
  @moduledoc """
  A struct representing a Nylas application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.{
    ApplicationRedirect,
    Schema.Util
  }

  @type t :: %__MODULE__{
          application_id: String.t(),
          organization_id: String.t(),
          region: String.t(),
          created_at: non_neg_integer(),
          updated_at: non_neg_integer(),
          environment: String.t(),
          v2_organization_id: String.t(),
          branding: %__MODULE__.Branding{
            name: String.t(),
            icon_url: String.t(),
            website_url: String.t(),
            description: String.t()
          },
          hosted_authentication: %__MODULE__.HostedAuthentication{
            background_image_url: String.t(),
            alignment: atom(),
            color_primary: String.t(),
            color_secondary: String.t(),
            title: String.t(),
            subtitle: String.t(),
            background_color: String.t(),
            spacing: non_neg_integer()
          },
          callback_uris: [ApplicationRedirect.t()]
        }

  @primary_key false

  embedded_schema do
    field :application_id, :string
    field :organization_id, :string
    field :region, Ecto.Enum, values: ~w(us eu)a
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
