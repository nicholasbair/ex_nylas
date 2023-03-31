defmodule ExNylas.Job do
  @moduledoc """
  A struct representing a job.
  """

  defstruct [
    :account_id,
    :action,
    :created_at,
    :id,
    :job_status_id,
    :object,
    :status,
    :reason,
  ]

  @typedoc "A job"
  @type t :: %__MODULE__{
    account_id: String.t(),
    action: String.t(),
    created_at: non_neg_integer(),
    id: String.t(),
    job_status_id: String.t(),
    object: String.t(),
    status: String.t(),
    reason: String.t(),
  }

  def as_struct() do
    %ExNylas.Job{}
  end

  def as_list(), do: [as_struct()]
end

defmodule ExNylas.Jobs do
  @moduledoc """
  Interface for Nylas job.
  """

  use ExNylas,
    object: "job-statuses",
    struct: ExNylas.Job,
    include: [:list, :first, :find, :all]
end
