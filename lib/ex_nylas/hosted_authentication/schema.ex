defmodule ExNylas.Schema.HostedAuthentication do
  @moduledoc """
  Structs for Nylas hosted authentication.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  schema "hosted_authentication" do
    field :access_token, :string
    field :expires_in, :integer
    field :id_token, :string
    field :refresh_token, :string
    field :scope, :string
    field :token_type, :string
    field :grant_id, :string

    embeds_one :options, Options do
      field :provider, :string
      field :redirect_uri, :string
      field :scopes, {:array, :string}
      field :state, :string
      field :login_hint, :string
      field :access_type, :string
      field :code_challenge, :string
      field :code_challenge_method, :string
      field :credential_id, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:access_token, :expires_in, :id_token, :refresh_token, :scope, :token_type, :grant_id])
    |> cast_embed(:options, with: &Util.embedded_changeset/2)
    |> validate_required([:grant_id])
  end
end
