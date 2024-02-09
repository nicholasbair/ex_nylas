defmodule ExNylas.Schema.Common.EmailParticipant do
  @moduledoc """
  A struct representing an email participant.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "email_participant" do
    field :email, :string
    field :name, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
