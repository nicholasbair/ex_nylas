defmodule ExNylas.Application do
  @moduledoc """
  A struct representing a Nylas application.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.{
    ApplicationRedirect,
    Schema.Util
  }

  @primary_key false

  typed_embedded_schema do
    field(:application_id, :string)
    field(:created_at, :integer) :: non_neg_integer() | nil
    field(:environment, Ecto.Enum, values: ~w(production staging development sandbox)a)
    field(:organization_id, :string)
    field(:region, Ecto.Enum, values: ~w(us eu)a)
    field(:updated_at, :integer) :: non_neg_integer() | nil
    field(:v2_application_id, :string)

    embeds_one :branding, Branding, primary_key: false do
      field(:description, :string)
      field(:icon_url, :string)
      field(:name, :string)
      field(:website_url, :string)
    end

    embeds_many :callback_uris, ApplicationRedirect

    embeds_one :hosted_authentication, HostedAuthentication, primary_key: false do
      field(:alignment, Ecto.Enum, values: ~w(left center right)a)
      field(:background_color, :string)
      field(:background_image_url, :string)
      field(:color_primary, :string)
      field(:color_secondary, :string)
      field(:spacing, :integer)
      field(:subtitle, :string)
      field(:title, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:application_id, :organization_id, :region, :created_at, :updated_at, :environment, :v2_application_id])
    |> cast_embed(:branding, with: &Util.embedded_changeset/2)
    |> cast_embed(:hosted_authentication, with: &Util.embedded_changeset/2)
    |> cast_embed(:callback_uris)
  end
end
