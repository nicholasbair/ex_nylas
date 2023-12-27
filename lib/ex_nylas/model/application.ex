defmodule ExNylas.Model.Application do
  @moduledoc """
  A struct representing a Nylas application.
  """

  use TypedStruct
  alias ExNylas.Model.{
    Application.Branding,
    Application.HostedAuthentication,
    ApplicationRedirect
  }

  typedstruct do
    field(:application_id, String.t())
    field(:organization_id, String.t())
    field(:region, String.t())
    field(:branding, Branding.t())
    field(:hosted_authentication, HostedAuthentication.t())
    field(:created_at, non_neg_integer())
    field(:updated_at, non_neg_integer())
    field(:environment, String.t())
    field(:v2_organization_id, String.t())
    field(:callback_uris, [ApplicationRedirect])
  end

  def as_list do
    %__MODULE__{
      branding: Branding.as_struct(),
      hosted_authentication: HostedAuthentication.as_struct(),
      callback_uris: [ApplicationRedirect.as_struct()]
    }
  end

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

    def as_struct, do: struct(__MODULE__)
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

    def as_struct, do: struct(__MODULE__)
  end
end
