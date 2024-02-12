defmodule ExNylas.Schema.Contact.Build.WebPage do
  @moduledoc """
  Helper module for validating the web page subobject on a contact request.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "email" do
    field :url, :string
    field :type, Ecto.Enum, values: [:work, :home, :other]
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:url])
  end
end
