defmodule ExNylas.WebhookNotification.Grant do
  @moduledoc """
  A struct representing a grant webhook notification.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          code: non_neg_integer(),
          grant_id: String.t(),
          integration_id: String.t(),
          provider: String.t(),
          reauthentication_flag: boolean()
        }

  @primary_key false

  embedded_schema do
    field :code, :integer
    field :grant_id, :string
    field :integration_id, :string
    field :provider, :string
    field :reauthentication_flag, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:code, :grant_id, :integration_id, :provider, :reauthentication_flag])
  end
end
