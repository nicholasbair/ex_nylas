defmodule ExNylas.HostedAuthentication.Options.Build do
  @moduledoc """
  Helper module to validate options for hosted authentication.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :provider, Ecto.Enum, values: ~w(google microsoft imap yahoo)a
    field :redirect_uri, :string
    field :response_type, Ecto.Enum, values: ~w(code adminconsent)a, default: :code
    field :scope, {:array, :string}
    field :prompt, Ecto.Enum, values: ~w(select_provider detect select_provider,detect detect,select_provider)a
    field :state, :string
    field :login_hint, :string
    field :access_type, Ecto.Enum, values: ~w(offline online)a
    field :code_challenge, :string
    field :code_challenge_method, Ecto.Enum, values: ~w(S256 plain)a
    field :credential_id, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:redirect_uri, :response_type])
  end
end
