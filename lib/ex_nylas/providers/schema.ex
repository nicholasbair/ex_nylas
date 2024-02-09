defmodule ExNylas.Schema.Provider do
  @moduledoc """
  Structs for Nylas providers.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "provider" do
    field :provider, :string
    field :type, :string
    field :email_address, :string
    field :detected, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
