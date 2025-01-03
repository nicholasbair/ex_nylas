defmodule ExNylas.Build.EventConferencing do
  @moduledoc """
  Helper module for validating an event conferencing before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false
  @derive {Jason.Encoder, only: [:autocreate, :provider, :details]}

  typed_embedded_schema do
    field(:autocreate, :map)
    field(:provider, Ecto.Enum, values: [:"Google Meet", :"Zoom Meeting", :"Microsoft Teams", :"Teams for Business", :teamsForBusiness], null: false)

    embeds_one :details, Details, primary_key: false do
      @derive {Jason.Encoder, only: [:meeting_code, :password, :url, :phone, :pin]}
      field(:meeting_code, :string)
      field(:password, :string)
      field(:phone, {:array, :string})
      field(:pin, :string)
      field(:url, :string)
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:autocreate, :provider])
    |> cast_embed(:details, with: &embedded_changeset/2)
    |> validate_type()
  end

  defp validate_type(changeset) do
    case {exists?(changeset, :autocreate), exists?(changeset, :details)} do
      {false, false} ->
        add_error(changeset, :autocreate, "cannot have both autocreate and details")
      _ ->
        changeset
    end
  end

  defp exists?(changeset, field) do
    changeset
    |> get_field(field)
    |> is_nil()
  end
end
