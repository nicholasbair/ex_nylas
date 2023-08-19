defmodule ExNylas.Common do

  defmodule Response do
    defstruct [
      :request_id,
      :data,
      :error,
      :next_cursor
    ]

    @type t :: %__MODULE__{
      request_id: String.t(),
      data: map(),
      error: ExNylas.Common.Error.t(),
      next_cursor: String.t()
    }

    def as_struct(), do: %ExNylas.Common.Response{}
    def as_struct(data_struct), do: %ExNylas.Common.Response{data: data_struct}
  end

  defmodule Error do
    defstruct [
      :type,
      :message,
      :provider_error
    ]

    @type t :: %__MODULE__{
      type: String.t(),
      message: String.t(),
      provider_error: Map.t(),
    }

    def as_struct(), do: %ExNylas.Common.Error{}
  end

  defmodule EmailParticipant do
    @enforce_keys [:email]
    defstruct [:email, :name]

    @type t :: %__MODULE__{
      email: String.t(),
      name: String.t()
    }

    def as_struct() do
      %ExNylas.Common.EmailParticipant{email: nil}
    end
  end

end
