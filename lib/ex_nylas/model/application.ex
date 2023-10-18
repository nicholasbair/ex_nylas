defmodule ExNylas.Model.Application do
  @moduledoc """
  A struct representing a Nylas application.
  """

  use TypedStruct

  typedstruct do
    field(:application_id, String.t())
    field(:organization_id, String.t())
    field(:region, String.t())
  end

  def as_list(), do: struct(__MODULE__)

  defmodule Branding do
    @moduledoc """
    A struct representing a Nylas application's branding.
    """

    typedstruct do
      field(:name, String.t())
      field(:icon_url, String.t())
      field(:website_url, String.t())
      field(:description, String.t())
    end

    def as_struct(), do: struct(__MODULE__)
  end

  defmodule HostedAuthentication do
    @moduledoc """
    A struct representing a Nylas application's hosted authentication.
    """

    typedstruct do
      field(:background_image_url, String.t())
      field(:alignment, String.t())
      field(:color_primary, String.t())
      field(:color_secondary, String.t())
      field(:title, String.t())
      field(:subtitle, String.t())
      field(:background_color, String.t())
      field(:spacing, integer())
    end

    def as_struct(), do: struct(__MODULE__)
  end
end
