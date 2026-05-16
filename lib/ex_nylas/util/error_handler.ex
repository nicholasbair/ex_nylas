defmodule ExNylas.ErrorHandler do
  @moduledoc """
  Common error handling utilities for bang (!) functions.

  This module provides a centralized way to handle errors in bang functions,
  ensuring consistent error raising behavior across the entire library.
  """

  alias ExNylas.{
    APIError,
    Response
  }

  @doc """
  Raises an appropriate exception based on the error type.

  Handles three error cases:
  1. `APIError` wrapped in `Response` - raises the `APIError` directly
  2. `Response` without `APIError` - creates `APIError` from status
  3. Other exceptions - raises them directly

  ## Examples

      iex> error = %ExNylas.APIError{message: "Bad request"}
      iex> ExNylas.ErrorHandler.raise_error(%ExNylas.Response{error: error, status: 400})
      ** (ExNylas.APIError) Bad request

      iex> ExNylas.ErrorHandler.raise_error(%ExNylas.Response{status: 500})
      ** (ExNylas.APIError) API request failed with status 500

      iex> ExNylas.ErrorHandler.raise_error(%RuntimeError{message: "Something went wrong"})
      ** (RuntimeError) Something went wrong
  """
  @spec raise_error(Response.t() | Exception.t()) :: no_return()
  def raise_error(%Response{error: %APIError{} = error}), do: raise(error)

  def raise_error(%Response{} = resp),
    do: raise(APIError.exception(%{message: "API request failed with status #{resp.status}"}))

  def raise_error(exception), do: raise(exception)
end
