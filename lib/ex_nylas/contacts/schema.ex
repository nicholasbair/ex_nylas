defmodule ExNylas.Contact do
  @moduledoc """
  A struct representing a contact.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @type t :: %__MODULE__{
          given_name: String.t(),
          grant_id: String.t(),
          id: String.t(),
          job_title: String.t(),
          manager_name: String.t(),
          notes: String.t(),
          office_location: String.t(),
          object: String.t(),
          source: String.t(),
          emails: [
            %__MODULE__.Email{
              email: String.t(),
              type: String.t()
            }
          ],
          groups: [
            %__MODULE__.ContactGroup{
              id: String.t(),
              name: String.t()
            }
          ],
          im_addresses: [
            %__MODULE__.ImAddress{
              im_address: String.t(),
              type: String.t()
            }
          ],
          phone_numbers: [
            %__MODULE__.PhoneNumber{
              number: String.t(),
              type: String.t()
            }
          ],
          physical_addresses: [
            %__MODULE__.PhysicalAddress{
              type: String.t(),
              format: String.t(),
              street_address: String.t(),
              city: String.t(),
              state: String.t(),
              postal_code: String.t(),
              country: String.t()
            }
          ],
          web_pages: [
            %__MODULE__.WebPage{
              url: String.t(),
              type: String.t()
            }
          ]
        }

  @primary_key false

  embedded_schema do
    field :given_name, :string
    field :grant_id, :string
    field :id, :string
    field :job_title, :string
    field :manager_name, :string
    field :notes, :string
    field :office_location, :string
    field :object, :string
    field :source, Ecto.Enum, values: ~w(address_book domain inbox)a

    embeds_many :emails, Email, primary_key: false do
      field :email, :string
      field :type, :string
    end

    embeds_many :groups, ContactGroup, primary_key: false do
      field :id, :string
      field :name, :string
    end

    embeds_many :im_addresses, ImAddress, primary_key: false do
      field :im_address, :string
      field :type, :string
    end

    embeds_many :phone_numbers, PhoneNumber, primary_key: false do
      field :number, :string
      field :type, Ecto.Enum, values: ~w(work home other)a
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
      field :type, Ecto.Enum, values: ~w(work home other)a
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:given_name, :grant_id, :id, :job_title, :manager_name, :notes, :office_location, :object, :source])
    |> cast_embed(:emails, with: &Util.embedded_changeset/2)
    |> cast_embed(:groups, with: &Util.embedded_changeset/2)
    |> cast_embed(:im_addresses, with: &Util.embedded_changeset/2)
    |> cast_embed(:phone_numbers, with: &Util.embedded_changeset/2)
    |> cast_embed(:physical_addresses, with: &Util.embedded_changeset/2)
    |> cast_embed(:web_pages, with: &Util.embedded_changeset/2)
    |> validate_required([:grant_id, :id])
  end
end
