defmodule ExNylas.HostedAuthentication.Grant do
  @moduledoc """
  Structs for Nylas hosted authentication.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/authentication-apis)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:access_token, :string)
    field(:email, :string)
    field(:expires_in, :integer) :: non_neg_integer() | nil
    field(:grant_id, :string)
    field(:id_token, :string)
    field(:provider, Ecto.Enum, values: ~w(google microsoft icloud yahoo imap virtual-calendar zoom ews)a)
    field(:refresh_token, :string)
    field(:scope, :string)
    field(:token_type, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:access_token, :expires_in, :id_token, :refresh_token, :scope, :token_type, :grant_id, :provider, :email])
  end
end
