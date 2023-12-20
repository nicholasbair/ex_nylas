defmodule ExNylas.Model.Contact do
  @moduledoc """
  A struct representing a contact.
  """

  alias ExNylas.Model.{
    Contact.Email,
    Contact.ImAddress,
    Contact.PhoneNumber,
    Contact.PhysicalAddress,
    Contact.WebPage,
    ContactGroup
  }

  use TypedStruct

  typedstruct do
    field(:emails, [Email.t()])
    field(:given_name, String.t())
    field(:grant_id, String.t())
    field(:groups, [ContactGroup.t()])
    field(:id, String.t())
    field(:im_addresses, [ImAddress.t()])
    field(:job_title, String.t())
    field(:manager_name, String.t())
    field(:notes, String.t())
    field(:office_location, String.t())
    field(:object, String.t())
    field(:phone_numbers, [PhoneNumber.t()])
    field(:physical_addresses, [PhysicalAddress.t()])
    field(:source, String.t())
    field(:web_pages, [WebPage.t()])
  end

  def as_struct do
    %__MODULE__{
      emails: Email.as_list(),
      groups: ContactGroup.as_list(),
      im_addresses: ImAddress.as_list(),
      phone_numbers: PhoneNumber.as_list(),
      physical_addresses: PhysicalAddress.as_list(),
      web_pages: WebPage.as_list()
    }
  end

  def as_list, do: [as_struct()]

  typedstruct module: Build do
    field(:given_name, String.t(), enforce: true)
    field(:emails, [map()], enforce: true)
  end

  defmodule Email do
    @moduledoc """
    A struct representing a contact's email address.
    """

    use TypedStruct

    typedstruct do
      field(:email, String.t())
      field(:type, String.t())
    end

    def as_struct, do: struct(__MODULE__)

    def as_list, do: [as_struct()]
  end

  defmodule ImAddress do
    @moduledoc """
    A struct representing a contact's IM address.
    """

    use TypedStruct

    typedstruct do
      field(:im_address, String.t())
      field(:type, String.t())
    end

    def as_struct, do: struct(__MODULE__)

    def as_list, do: [as_struct()]
  end

  defmodule PhoneNumber do
    @moduledoc """
    A struct representing a contact's phone number.
    """

    use TypedStruct

    typedstruct do
      field(:number, String.t())
      field(:type, String.t())
    end

    def as_struct, do: struct(__MODULE__)

    def as_list, do: [as_struct()]
  end

  defmodule PhysicalAddress do
    @moduledoc """
    A struct representing a contact's physical address.
    """

    use TypedStruct

    typedstruct do
      field(:street_address, String.t())
      field(:postal_code, String.t())
      field(:state, String.t())
      field(:country, String.t())
      field(:city, String.t())
      field(:type, String.t())
    end

    def as_struct, do: struct(__MODULE__)

    def as_list, do: [as_struct()]
  end

  defmodule WebPage do
    @moduledoc """
    A struct representing a contact's web page.
    """

    use TypedStruct

    typedstruct do
      field(:url, String.t())
      field(:type, String.t())
    end

    def as_struct, do: struct(__MODULE__)

    def as_list, do: [as_struct()]
  end
end
