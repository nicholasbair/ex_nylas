defmodule ExNylas.HostedAuthentication.Options.Build do
  @moduledoc """
  Helper module to validate options for hosted authentication.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/authentication-apis)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:access_type, Ecto.Enum, values: ~w(offline online)a)
    field(:code_challenge, :string)
    field(:code_challenge_method, Ecto.Enum, values: ~w(S256 plain)a)
    field(:credential_id, :string)
    field(:login_hint, :string)
    field(:prompt, Ecto.Enum, values: ~w(select_provider detect select_provider,detect detect,select_provider)a)
    field(:provider, Ecto.Enum, values: ~w(google microsoft icloud yahoo imap virtual-calendar zoom ews)a)
    field(:scope, {:array, :string})
    field(:state, :string)
    field(:redirect_uri, :string)
    field(:response_type, Ecto.Enum, values: ~w(code adminconsent)a, default: :code)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:redirect_uri, :response_type])
  end
end
