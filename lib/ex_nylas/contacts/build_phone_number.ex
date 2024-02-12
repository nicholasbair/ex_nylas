defmodule ExNylas.Schema.Contact.Build.PhoneNumber do
  @moduledoc """
  Helper module for validating the phone number subobject on a contact request.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "phone_number" do
    field :number, :string
    field :type, Ecto.Enum, values: ~w(work home other)a
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:number])
  end
end
