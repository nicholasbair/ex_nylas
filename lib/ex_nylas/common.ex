defmodule ExNylas.Common do

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
