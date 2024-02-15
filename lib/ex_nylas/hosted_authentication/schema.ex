defmodule ExNylas.HostedAuthentication.Grant do
  @moduledoc """
  Structs for Nylas hosted authentication.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :access_token, :string
    field :expires_in, :integer
    field :id_token, :string
    field :refresh_token, :string
    field :scope, {:array, :string}
    field :token_type, :string
    field :grant_id, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:access_token, :expires_in, :id_token, :refresh_token, :scope, :token_type, :grant_id])
    |> validate_required([:grant_id])
  end
end
