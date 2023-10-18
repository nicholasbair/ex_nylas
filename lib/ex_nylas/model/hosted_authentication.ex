defmodule ExNylas.Model.HostedAuthentication do
  @moduledoc """
  Structs for Nylas hosted authentication.
  """

  use TypedStruct

  typedstruct do
    field(:access_token, String.t())
    field(:expires_in, integer())
    field(:id_token, String.t())
    field(:refresh_token, String.t())
    field(:scope, String.t())
    field(:token_type, String.t())
    field(:grant_id, String.t())
  end

  typedstruct module: Options do
    field(:provider, String.t())
    field(:redirect_uri, String.t())
    field(:scopes, [String.t()])
    field(:state, String.t())
    field(:login_hint, String.t())
    field(:access_type, String.t())
    field(:code_challenge, String.t())
    field(:code_challenge_method, String.t())
    field(:credential_id, String.t())
  end

  def as_struct(), do: struct(__MODULE__)
end
