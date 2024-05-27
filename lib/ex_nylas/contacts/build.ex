defmodule ExNylas.Contact.Build do
  @moduledoc """
  Helper module for validating a contact before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @derive {Jason.Encoder, only: [:given_name, :job_title, :manager_name, :notes, :office_location, :object, :source, :emails, :im_addresses, :phone_numbers, :web_pages, :groups, :physical_addresses]}
  @primary_key false

  typed_embedded_schema do
    field :given_name, :string
    field :job_title, :string
    field :manager_name, :string
    field :notes, :string
    field :office_location, :string
    field :object, :string
    field :source, :string

    embeds_many :emails, Email, primary_key: false do
      @derive {Jason.Encoder, only: [:email, :type]}

      field :email, :string
      field :type, Ecto.Enum, values: ~w(work home other)a
    end

    embeds_many :im_addresses, ImAddress, primary_key: false do
      @derive {Jason.Encoder, only: [:im_address, :type]}

      field :im_address, :string
      field :type, :string
    end

    embeds_many :phone_numbers, PhoneNumber, primary_key: false do
      @derive {Jason.Encoder, only: [:number, :type]}

      field :number, :string
      field :type, Ecto.Enum, values: ~w(work home other)a
    end

    embeds_many :web_pages, WebPage, primary_key: false do
      @derive {Jason.Encoder, only: [:url, :type]}

      field :url, :string
      field :type, Ecto.Enum, values: ~w(work home other)a
    end

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
    |> cast_embed(:emails, with: &email_changeset/2)
    |> cast_embed(:im_addresses, with: &im_changeset/2)
    |> cast_embed(:phone_numbers, with: &phone_changeset/2)
    |> cast_embed(:web_pages, with: &web_changeset/2)
    |> cast_embed(:groups, with: &contact_group_changeset/2)
    |> cast_embed(:physical_addresses, with: &Util.embedded_changeset/2)
    |> validate_required([:given_name])
  end

  def contact_group_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :name])
    |> validate_required([:id, :name])
  end

  def email_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :type])
    |> validate_required([:email])
    |> validate_length(:email, min: 1, max: 255)
  end

  def im_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:im_address, :type])
    |> validate_required([:im_address])
    |> validate_length(:im_address, min: 1, max: 255)
  end

  def phone_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number, :type])
    |> validate_required([:number])
  end

  def web_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :type])
    |> validate_required([:url])
  end
end
