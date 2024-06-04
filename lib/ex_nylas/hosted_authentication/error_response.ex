defmodule ExNylas.HostedAuthentication.Error do
  @moduledoc """
  A struct representing an error response from Nylas during the hosted auth code exchange.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:error, :string)
    field(:error_code, :integer)
    field(:error_uri, :string)
    field(:request_id, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
