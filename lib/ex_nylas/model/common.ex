defmodule ExNylas.Model.Common do
  @moduledoc """
  Common structs for ExNylas
  """

  use TypedStruct

  defmodule Response do
    @moduledoc """
    A struct representing the standard response from the Nylas API.
    """

    alias ExNylas.Model.Common.Error

    typedstruct do
      field(:request_id, String.t())
      field(:data, map())
      field(:error, Error.t())
      field(:next_cursor, String.t())
    end

    def as_struct(), do: struct(__MODULE__)

    def as_struct(data_struct) do
      %__MODULE__{
        data: data_struct,
        error: Error.as_struct()
      }
    end
  end

  defmodule Error do
    @moduledoc """
    A struct representing an error from the Nylas API.
    """

    typedstruct do
      field(:type, String.t())
      field(:message, String.t())
      field(:provider_error, map())
    end

    def as_struct(), do: struct(__MODULE__)
  end

  defmodule EmailParticipant do
    @moduledoc """
    A struct representing an email participant.
    """

    typedstruct do
      field(:email, String.t(), enforce: true)
      field(:name, String.t())
    end

    def as_struct(), do: struct(__MODULE__)
  end

  defmodule TrackingOptions do
    @moduledoc """
    A struct representing tracking options for a message/draft.
    """

    typedstruct do
      field(:links, boolean())
      field(:opens, boolean())
      field(:thread_replies, boolean())
      field(:label, String.t())
    end

    def as_struct(), do: struct(__MODULE__)
  end

  defmodule MessageHeader do
    @moduledoc """
    A struct representing the headers of a message.
    """

    typedstruct do
      field(:name, String.t())
      field(:value, String.t())
    end

    def as_struct(), do: struct(__MODULE__)
  end
end
