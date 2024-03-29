defmodule ExNylas.WebhookIP do
  @moduledoc """
  A struct for Nylas webhook IP.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "webhook_ip" do
    field :ip_addresses, {:array, :string}
    field :updated_at, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:ip_addresses])
  end
end
