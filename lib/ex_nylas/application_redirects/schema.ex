defmodule ExNylas.Schema.ApplicationRedirect do
  @moduledoc """
  A struct for Nylas application redirect.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "application_redirect" do
    field :id, :string
    field :url, :string
    field :platform, Ecto.Enum, values: ~w(web desktop js ios android)a
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
