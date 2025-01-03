defmodule ExNylas.Contact do
  @moduledoc """
  A struct representing a contact.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field(:birthday, :string)
    field(:company_name, :string)
    field(:given_name, :string)
    field(:grant_id, :string)
    field(:id, :string)
    field(:job_title, :string)
    field(:manager_name, :string)
    field(:notes, :string)
    field(:object, :string)
    field(:office_location, :string)
    field(:source, Ecto.Enum, values: ~w(address_book domain inbox)a)

    embeds_many :emails, Email, primary_key: false do
      field(:email, :string)
      field(:type, :string)
    end

    embeds_many :groups, ContactGroup, primary_key: false do
      field(:id, :string)
      field(:name, :string)
    end

    embeds_many :im_addresses, ImAddress, primary_key: false do
      field(:im_address, :string)
      field(:type, :string)
    end

    embeds_many :phone_numbers, PhoneNumber, primary_key: false do
      field(:number, :string)
      field(:type, Ecto.Enum, values: ~w(work home other mobile)a)
    end

    embeds_many :physical_addresses, PhysicalAddress, primary_key: false do
      field(:city, :string)
      field(:country, :string)
      field(:format, :string)
      field(:postal_code, :string)
      field(:state, :string)
      field(:street_address, :string)
      field(:type, :string)
    end

    embeds_many :web_pages, WebPage, primary_key: false do
      field(:url, :string)
      field(:type, Ecto.Enum, values: ~w(work home other)a)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:birthday, :company_name, :given_name, :grant_id, :id, :job_title, :manager_name, :notes, :office_location, :object, :source])
    |> cast_embed(:emails, with: &Util.embedded_changeset/2)
    |> cast_embed(:groups, with: &Util.embedded_changeset/2)
    |> cast_embed(:im_addresses, with: &Util.embedded_changeset/2)
    |> cast_embed(:phone_numbers, with: &Util.embedded_changeset/2)
    |> cast_embed(:physical_addresses, with: &Util.embedded_changeset/2)
    |> cast_embed(:web_pages, with: &Util.embedded_changeset/2)
  end
end
