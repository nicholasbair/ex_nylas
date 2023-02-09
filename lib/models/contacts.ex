defmodule ExNylas.Contact do
  @moduledoc """
  A struct representing a contact.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A contact"
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:given_name, String.t())
    field(:middle_name, String.t())
    field(:surname, String.t())
    field(:suffix, String.t())
    field(:nickname, String.t())
    field(:birthday, String.t())
    field(:company_name, String.t())
    field(:job_title, String.t())
    field(:manager_name, String.t())
    field(:office_location, String.t())
    field(:notes, String.t())
    field(:picture_url, String.t())
    field(:email_addresses, String.t())
    field(:im_addresses, list())
    field(:physical_addresses, list())
    field(:phone_numbers, list())
    field(:web_pages, list())
    field(:groups, list())
    field(:source, String.t())
  end

  defmodule Build do
    @moduledoc """
    A struct representing a contact.
    """
    use TypedStruct

    typedstruct do
      @typedoc "A contact"
      field(:given_name, String.t())
      field(:middle_name, String.t())
      field(:surname, String.t())
      field(:suffix, String.t())
      field(:nickname, String.t())
      field(:birthday, String.t())
      field(:company_name, String.t())
      field(:job_title, String.t())
      field(:manager_name, String.t())
      field(:office_location, String.t())
      field(:notes, String.t())
      field(:emails, String.t())
      field(:im_addresses, list())
      field(:physical_addresses, list())
      field(:phone_numbers, list())
      field(:web_pages, list())
      field(:group, String.t())
    end
  end
end

defmodule ExNylas.Contact.Group do
  @moduledoc """
  A struct representing a contact group.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A contact group"
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:name, String.t())
    field(:path, String.t())
  end
end

defmodule ExNylas.Contacts do
  @moduledoc """
  Interface for Nylas contacts.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF
  alias ExNylas.Contact.Group

  use ExNylas,
    object: "contacts",
    struct: ExNylas.Contact,
    include: [:list, :first, :find, :delete, :build, :create, :update]

  @doc """
  Get contacts groups.

  Example
      {:ok, result} = conn |> ExNylas.Contacts.groups()
  """
  def groups(%Conn{} = conn) do
    res =
      API.get(
        "#{conn.api_server}/contacts/groups",
        API.header_bearer(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, Group)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
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
    res =
      API.get(
        "#{conn.api_server}/contacts/#{id}/picture",
        API.header_bearer(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
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
