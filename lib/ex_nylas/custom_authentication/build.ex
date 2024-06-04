defmodule ExNylas.CustomAuthentication.Build do
  @moduledoc """
  Helper module for validating a custom authentication request.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @derive {Jason.Encoder, only: [:provider, :state, :settings]}
  @primary_key false

  typed_embedded_schema do
    field(:provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud)a, null: false)
    field(:state, :string)

    embeds_one :settings, Settings, primary_key: false do
      @derive {Jason.Encoder, only: [:refresh_token, :credential_id, :email_address, :imap_username, :imap_password, :imap_host, :imap_port, :smtp_host, :smtp_port]}

      field(:credential_id, :string)
      field(:email_address, :string)
      field(:refresh_token, :string)

      # IMAP specific fields
      field(:imap_username, :string)
      field(:imap_password, :string)
      field(:imap_host, :string)
      field(:imap_port, :integer) :: non_neg_integer() | nil
      field(:smtp_host, :string)
      field(:smtp_port, :integer) :: non_neg_integer() | nil
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:provider, :state, :settings])
    |> cast_embed(:settings, with: &Util.embedded_changeset/2)
    |> validate_required([:provider, :settings])
  end
end
