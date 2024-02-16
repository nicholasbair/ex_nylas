defmodule ExNylas.CustomAuthentication.Build do
  @moduledoc """
  Helper module for validating a custom authentication request.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @derive {Jason.Encoder, only: [:provider, :state, :settings]}
  @primary_key false

  embedded_schema do
    field :provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud)a
    field :state, :string

    embeds_one :settings, Settings, primary_key: false do
      @derive {Jason.Encoder, only: [:refresh_token, :credential_id, :email_address, :imap_username, :imap_password, :imap_host, :imap_port, :smtp_host, :smtp_port]}

      field :refresh_token, :string
      field :credential_id, :string
      field :email_address, :string

      # IMAP specific fields
      field :imap_username, :string
      field :imap_password, :string
      field :imap_host, :string
      field :imap_port, :integer
      field :smtp_host, :string
      field :smtp_port, :integer
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:provider, :state, :settings])
    |> cast_embed(:settings, with: &Util.embedded_changeset/2)
    |> validate_required([:provider, :settings])
  end
end
