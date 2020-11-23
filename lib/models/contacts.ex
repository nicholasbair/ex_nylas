defmodule ExNylas.Contact do
  @moduledoc """
  A struct representing a contact.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A contact"
    field :id,                 String.t()
    field :object,             String.t()
    field :account_id,         String.t()
    field :given_name,         String.t()
    field :middle_name,        String.t()
    field :surname,            String.t()
    field :suffix,             String.t()
    field :nickname,           String.t()
    field :birthday,           String.t()
    field :company_name,       String.t()
    field :job_title,          String.t()
    field :manager_name,       String.t()
    field :office_location,    String.t()
    field :notes,              String.t()
    field :picture_url,        String.t()
    field :email_addresses,    String.t()
    field :im_addresses,       list()
    field :physical_addresses, list()
    field :phone_numbers,      list()
    field :web_pages,          list()
    field :groups,             list()
    field :source,             String.t()
  end

end

defmodule ExNylas.Contact.Group do
  @moduledoc """
  A struct representing a contact group.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A contact group"
    field :id,         String.t()
    field :object,     String.t()
    field :account_id, String.t()
    field :name,       String.t()
    field :path,       String.t()
  end

end

defmodule ExNylas.Contacts do
  @moduledoc """
  Interface for Nylas contact.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF
  alias ExNylas.Contact.Group

  use ExNylas, object: "contacts", struct: ExNylas.Contact, except: [:search, :send]

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

  def groups!(%Conn{} = conn) do
    case groups(conn) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

end
