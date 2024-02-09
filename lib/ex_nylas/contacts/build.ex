defmodule ExNylas.Schema.Contact.Build do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

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

    embeds_many :emails, Email, primary_key: false do
      field :email, :string
      field :type, :string
    end

    embeds_many :groups, ContactGroup, primary_key: false do
      field :id, :string
      field :name, :string
    end

    embeds_many :im_addresses, ImAddress, primary_key: false do
      field :address, :string
      field :type, :string
    end

    embeds_many :phone_numbers, PhoneNumber, primary_key: false do
      field :number, :string
      field :type, :string
    end

    embeds_many :physical_addresses, PhysicalAddress, primary_key: false do
      field :type, :string
      field :format, :string
      field :street_address, :string
      field :city, :string
      field :state, :string
      field :postal_code, :string
      field :country, :string
    end

    embeds_many :web_pages, WebPage, primary_key: false do
      field :url, :string
      field :type, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:given_name, :job_title, :manager_name, :notes, :office_location, :object, :source])
    |> cast_embed(:emails, with: &Util.embedded_changeset/2)
    |> cast_embed(:groups, with: &Util.embedded_changeset/2)
    |> cast_embed(:im_addresses, with: &Util.embedded_changeset/2)
    |> cast_embed(:phone_numbers, with: &Util.embedded_changeset/2)
    |> cast_embed(:physical_addresses, with: &Util.embedded_changeset/2)
    |> cast_embed(:web_pages, with: &Util.embedded_changeset/2)
    |> validate_required([:given_name])
  end
end
