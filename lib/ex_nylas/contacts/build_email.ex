defmodule ExNylas.Schema.Contact.Build.Email do
  @moduledoc """
  Helper module for validating the email subobject on a contact request.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "email" do
    field :email, :string
    field :type, Ecto.Enum, values: ~w(work home other)a
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:email])
    |> validate_length(:email, min: 1, max: 255)
  end
end
