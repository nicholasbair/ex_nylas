defmodule ExNylas.Schema.Contact.Build do
  @moduledoc """
  Helper module for validating a contact before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Schema.Util
  alias ExNylas.Schema.Contact.Build.{
    Email,
    ImAddress,
    PhoneNumber,
    WebPage
  }

  @derive {Jason.Encoder, only: [:given_name, :job_title, :manager_name, :notes, :office_location, :object, :source]}
  @primary_key false

  schema "contact" do
    field :given_name, :string
    field :job_title, :string
    field :manager_name, :string
    field :notes, :string
    field :office_location, :string
    field :object, :string
    field :source, :string

    embeds_many :emails, Email
    embeds_many :im_addresses, ImAddress
    embeds_many :phone_numbers, PhoneNumber
    embeds_many :web_pages, WebPage

    embeds_many :groups, ContactGroup, primary_key: false do
      @derive {Jason.Encoder, only: [:id, :name]}

      field :id, :string
      field :name, :string
    end

    embeds_many :physical_addresses, PhysicalAddress, primary_key: false do
      @derive {Jason.Encoder, only: [:type, :format, :street_address, :city, :state, :postal_code, :country]}

      field :type, :string
      field :format, :string
      field :street_address, :string
      field :city, :string
      field :state, :string
      field :postal_code, :string
      field :country, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:given_name, :job_title, :manager_name, :notes, :office_location, :object, :source])
    |> cast_embed(:emails, with: &Email.changeset/2)
    |> cast_embed(:im_addresses, with: &ImAddress.changeset/2)
    |> cast_embed(:phone_numbers, with: &PhoneNumber.changeset/2)
    |> cast_embed(:web_pages, with: &WebPage.changeset/2)
    |> cast_embed(:groups, with: &Util.embedded_changeset/2)
    |> cast_embed(:physical_addresses, with: &Util.embedded_changeset/2)
    |> validate_required([:given_name])
  end
end
