defmodule ExNylas.HostedAuthentication.Grant do
  @moduledoc """
  Structs for Nylas hosted authentication.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:access_token, :string)
    field(:email, :string, null: false)
    field(:expires_in, :integer) :: non_neg_integer()
    field(:grant_id, :string, null: false)
    field(:id_token, :string)
    field(:provider, Ecto.Enum, values: ~w(google microsoft icloud yahoo imap virtual-calendar zoom ews)a, null: false)
    field(:refresh_token, :string)
    field(:scope, :string)
    field(:token_type, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:access_token, :expires_in, :id_token, :refresh_token, :scope, :token_type, :grant_id, :provider, :email])
    |> validate_required([:grant_id, :provider, :email])
  end
end
