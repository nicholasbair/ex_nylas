defmodule ExNylas.Contact do
  @moduledoc """
  A struct representing a contact.
  """

  defstruct [
    :id,
    :object,
    :account_id,
    :given_name,
    :middle_name,
    :surname,
    :suffix,
    :nickname,
    :birthday,
    :company_name,
    :job_title,
    :manager_name,
    :office_location,
    :notes,
    :picture_url,
    :emails,
    :im_addresses,
    :physical_addresses,
    :phone_numbers,
    :web_pages,
    :groups,
    :source,
  ]

  @typedoc "A contact"
  @type t :: %__MODULE__{
    id: String.t(),
    object: String.t(),
    account_id: String.t(),
    given_name: String.t(),
    middle_name: String.t(),
    surname: String.t(),
    suffix: String.t(),
    nickname: String.t(),
    birthday: String.t(),
    company_name: String.t(),
    job_title: String.t(),
    manager_name: String.t(),
    office_location: String.t(),
    notes: String.t(),
    picture_url: String.t(),
    emails: [ExNylas.Contact.EmailAddress.t()],
    im_addresses: [ExNylas.Contact.IMAddress.t()],
    physical_addresses: [ExNylas.Contact.PhysicalAddress.t()],
    phone_numbers: [ExNylas.Contact.PhoneNumber.t()],
    web_pages: [ExNylas.Contact.WebPage.t()],
    groups: [ExNylas.Contact.Group.t()],
    source: String.t(),
  }

  defmodule EmailAddress do

    defstruct [
      :type,
      :email,
    ]

    @type t :: %__MODULE__{
      type: String.t(),
      email: String.t(),
    }
  end

  defmodule IMAddress do
    # @derive Nestru.Decoder
    # use Domo, skip_defaults: true

    defstruct [
      :type,
      :im_address,
    ]

    @type t :: %__MODULE__{
      type: String.t(),
      im_address: String.t(),
    }
  end

  defmodule PhysicalAddress do
    # @derive Nestru.Decoder
    # use Domo, skip_defaults: true

    defstruct [
      :format,
      :type,
      :street_address,
      :city,
      :postal_code,
      :state,
      :country,
      :secondary_address
    ]

    @type t :: %__MODULE__{
      format: String.t(),
      type: String.t(),
      street_address: String.t(),
      city: String.t(),
      postal_code: String.t(),
      state: String.t(),
      country: String.t(),
      secondary_address: String.t(),
    }
  end

  defmodule PhoneNumber do
    defstruct [
      :type,
      :number,
    ]

    @type t :: %__MODULE__{
      type: String.t(),
      number: String.t(),
    }
  end

  defmodule WebPage do
    defstruct [
      :type,
      :url,
    ]

    @type t :: %__MODULE__{
      type: String.t(),
      url: String.t(),
    }
  end

  defmodule Build do

    defstruct [
      :given_name,
      :middle_name,
      :surname,
      :suffix,
      :nickname,
      :birthday,
      :company_name,
      :job_title,
      :manager_name,
      :office_location,
      :notes,
      :emails,
      :im_addresses,
      :physical_addresses,
      :phone_numbers,
      :web_pages,
      :group,
    ]

    @typedoc "A struct representing the create contact request payload."
    @type t :: %__MODULE__{
      given_name: String.t(),
      middle_name: String.t(),
      surname: String.t(),
      suffix: String.t(),
      nickname: String.t(),
      birthday: String.t(),
      company_name: String.t(),
      job_title: String.t(),
      manager_name: String.t(),
      office_location: String.t(),
      notes: String.t(),
      emails: [ExNylas.Contact.EmailAddress.t()],
      im_addresses: [ExNylas.Contact.IMAddress.t()],
      physical_addresses: [ExNylas.Contact.PhysicalAddress.t()],
      phone_numbers: [ExNylas.Contact.PhoneNumber.t()],
      web_pages: [ExNylas.Contact.WebPage.t()],
      group: String.t(),
    }

  end

  defmodule Group do
    defstruct [
      :id,
      :object,
      :account_id,
      :name,
      :path,
    ]

    @typedoc "A contact group"
    @type t :: %__MODULE__{
      id: String.t(),
      object: String.t(),
      account_id: String.t(),
      name: String.t(),
      path: String.t(),
    }

    def as_struct() do
      %ExNylas.Contact.Group{}
    end

    def as_list(), do: [as_struct()]

  end

  def as_struct() do
    %ExNylas.Contact{
      emails: [%ExNylas.Contact.EmailAddress{}],
      im_addresses: [%ExNylas.Contact.IMAddress{}],
      physical_addresses: [%ExNylas.Contact.PhysicalAddress{}],
      phone_numbers: [%ExNylas.Contact.PhoneNumber{}],
      web_pages: [%ExNylas.Contact.WebPage{}],
      groups: [%ExNylas.Contact.Group{}],
    }
  end

  def as_list, do: [as_struct()]
end

defmodule ExNylas.Contacts do
  @moduledoc """
  Interface for Nylas contacts.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Contact.Group

  use ExNylas,
    object: "contacts",
    struct: ExNylas.Contact,
    include: [:list, :first, :find, :delete, :build, :create, :update, :all]

  @doc """
  Get contacts groups.

  Example
      {:ok, result} = conn |> ExNylas.Contacts.groups()
  """
  def groups(%Conn{} = conn) do
    API.get(
      "#{conn.api_server}/contacts/groups",
      API.header_bearer(conn)
    )
    |> API.handle_response(Group.as_list())
  end

  @doc """
  Get contacts groups.

  Example
      result = conn |> ExNylas.Contacts.groups!()
  """
  def groups!(%Conn{} = conn) do
    case groups(conn) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Get a contact's picture.

  Example
      {:ok, binary} = conn |> ExNylas.Contacts.get_picture(`id`)
  """
  def get_picture(%Conn{} = conn, id) do
    API.get(
      "#{conn.api_server}/contacts/#{id}/picture",
      API.header_bearer(conn)
    )
    |> API.handle_response()
  end

  @doc """
  Get a contact's picture.

  Example
      binary = conn |> ExNylas.Contacts.get_picture!(`id`)
  """
  def get_picture!(%Conn{} = conn, id) do
    case get_picture(conn, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
