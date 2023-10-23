defmodule ExNylas do
  @moduledoc """
  Generate functions that follow the 'standard' path.
  """

  alias ExNylas.Connection, as: Conn
  alias ExNylas.API, as: API

  @funcs %{
    list: %{name: :list, http_method: :get},
    first: %{name: :first, http_method: :get},
    search: %{name: :search, http_method: :get},
    find: %{name: :find, http_method: :get},
    delete: %{name: :delete, http_method: :delete},
    send: %{name: :send, http_method: :post},
    build: %{name: :build},
    all: %{name: :all},
    update: %{name: :update, http_method: :patch},
    create: %{name: :create, http_method: :post}
  }

  defp generate_funcs(opts) do
    include = Keyword.get(opts, :include, [])
    object = Keyword.get(opts, :object)
    struct_name = Keyword.get(opts, :struct)
    header_type = Keyword.get(opts, :header_type, :header_bearer)
    use_admin_url = Keyword.get(opts, :use_admin_url, false)

    @funcs
    |> Map.keys()
    |> Enum.filter(fn k -> k in include end)
    |> Enum.map(fn k ->
      Map.get(@funcs, k)
      |> generate_api(object, struct_name, header_type, use_admin_url)
    end)
  end

  defp generate_api(%{name: :all} = config, _object, struct_name, _header_type, _use_admin_url) do
    quote do
      @doc """
      Fetch all #{unquote(struct_name)}(s) matching the provided query (function will handle paging).

      Example
        {:ok, result} = ExNylas.#{__MODULE__}.all(conn, params)
      """
      def unquote(config.name)(%Conn{} = conn, params \\ %{}) do
        apply(ExNylas.Paging, :all, [conn, __MODULE__, params])
      end

      @doc """
      Fetch all #{unquote(struct_name)}(s) matching the provided query (function will handle paging).

      Example
        result = ExNylas.#{__MODULE__}.all!(conn, params)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, params \\ %{}) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{name: :build} = config, _object, struct_name, _header_type, _use_admin_url) do
    quote do
      @doc """
      Create and validate a #{unquote(struct_name)}, use the save function to send to Nylas.

      Example
        {:ok, result} = ExNylas.#{__MODULE__}.build(`payload`)
      """
      def unquote(config.name)(payload) do
        try do
          res = apply(__MODULE__, "#{unquote(config.name)}!" |> String.to_atom(), [payload])
          {:ok, res}
        rescue
          e in _ -> {:error, e}
        end
      end

      @doc """
      Create and validate a #{unquote(struct_name)}, use the save function to send to Nylas.

      Example
        result = ExNylas.#{__MODULE__}.build(`payload`)!
      """
      def unquote("#{config.name}!" |> String.to_atom())(payload) do
        unquote(struct_name)
        |> to_string()
        |> Kernel.<>(".Build")
        |> String.to_atom()
        |> struct!(payload)
      end
    end
  end

  defp generate_api(
         %{http_method: :get, name: :first} = config,
         object,
         struct_name,
         header_type,
         use_admin_url
       ) do
    quote do
      @doc """
      Get the first #{unquote(struct_name)}.

      Example
          {:ok, result} = conn |> ExNylas.#{__MODULE__}.first()
      """
      def unquote(config.name)(%Conn{} = conn, params \\ %{}) do
        headers = apply(API, unquote(header_type), [conn])
        url = ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object))
        val = apply(unquote(struct_name), :as_list, [])

        res =
          apply(
            API,
            unquote(config.http_method),
            [
              url,
              headers,
              [
                timeout: conn.timeout,
                recv_timeout: conn.recv_timeout,
                params: Map.put(params, :limit, 1)
              ]
            ]
          )
          |> API.handle_response(val)

        case res do
          {:ok, val} -> {:ok, %{val | data: Enum.at(val.data, 0)}}
          val -> val
        end
      end

      @doc """
      Get the first #{unquote(struct_name)}.

      Example
          result = conn |> ExNylas.#{__MODULE__}.first!()
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, params \\ %{}) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(
         %{http_method: :get, name: :search} = config,
         object,
         struct_name,
         header_type,
         use_admin_url
       ) do
    quote do
      @doc """
      Search for #{unquote(struct_name)}(s) based on provided `search_text`.

      Example
          {:ok, result} = conn |> ExNylas.#{__MODULE__}.search("nylas")
      """
      def unquote(config.name)(%Conn{} = conn, search_text) do
        headers = apply(API, unquote(header_type), [conn])
        url = ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object))
        val = apply(unquote(struct_name), :as_list, [])

        apply(
          API,
          unquote(config.http_method),
          [
            url,
            headers,
            [
              timeout: conn.timeout,
              recv_timeout: conn.recv_timeout,
              params: %{q: search_text}
            ]
          ]
        )
        |> API.handle_response(val)
      end

      @doc """
      Search for #{unquote(struct_name)}(s) based on provided `search_text`.

      Example
          result = conn |> ExNylas.#{__MODULE__}.search!("nylas")
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, search_text) do
        case unquote(config.name)(conn, search_text) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(
         %{http_method: method, name: name} = config,
         object,
         struct_name,
         header_type,
         use_admin_url
       )
       when name in [:find, :delete] and method in [:get, :delete] do
    quote do
      @doc """
      #{unquote(config.name) |> to_string |> String.capitalize()} a(n) #{unquote(struct_name)}.

      Example
          {:ok, result} = conn |> ExNylas.#{__MODULE__}.#{unquote(config.name)}(`id`)
      """
      def unquote(config.name)(%Conn{} = conn, id, params \\ %{}) do
        headers = apply(API, unquote(header_type), [conn])
        url = ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object))
        val = apply(unquote(struct_name), :as_struct, [])

        apply(
          API,
          unquote(method),
          [
            url,
            headers,
            [
              timeout: conn.timeout,
              recv_timeout: conn.recv_timeout,
              params: params
            ]
          ]
        )
        |> API.handle_response(val)
      end

      @doc """
      #{unquote(config.name) |> to_string |> String.capitalize()} a(n) #{unquote(struct_name)}.

      Example
          result = conn |> ExNylas.#{__MODULE__}.#{unquote(config.name)}!(`id`)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, id) do
        case unquote(config.name)(conn, id) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(
         %{http_method: :get} = config,
         object,
         struct_name,
         header_type,
         use_admin_url
       ) do
    quote do
      @doc """
      Fetch #{unquote(struct_name)}(s), optionally provide query `params`.

      Example
          {:ok, result} = conn |> ExNylas.#{__MODULE__}.#{unquote(config.name)}()
      """
      def unquote(config.name)(%Conn{} = conn, params \\ %{}) do
        headers = apply(API, unquote(header_type), [conn])
        url = ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object))
        val = apply(unquote(struct_name), :as_list, [])

        apply(
          API,
          unquote(config.http_method),
          [
            url,
            headers,
            [
              timeout: conn.timeout,
              recv_timeout: conn.recv_timeout,
              params: params
            ]
          ]
        )
        |> API.handle_response(val)
      end

      @doc """
      Fetch #{unquote(struct_name)}(s), optionally provide query `params`.

      Example
          result = conn |> ExNylas.#{__MODULE__}.#{unquote(config.name)}!()
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, params \\ %{}) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(
         %{http_method: :patch} = config,
         object,
         struct_name,
         header_type,
         use_admin_url
       ) do
    quote do
      @doc """
      Update a(n) #{unquote(struct_name)}.

      Example
          {:ok, result} = conn |> ExNylas.#{__MODULE__}.#{unquote(config.name)}(`id`, `body`, `params`)
      """
      def unquote(config.name)(%Conn{} = conn, id, changeset, params \\ %{}) do
        headers = apply(API, unquote(header_type), [conn]) ++ ["content-type": "application/json"]
        url = ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object))
        val = apply(unquote(struct_name), :as_struct, [])

        apply(
          API,
          unquote(config.http_method),
          [
            url,
            changeset,
            headers,
            [
              timeout: conn.timeout,
              recv_timeout: conn.recv_timeout,
              params: params
            ]
          ]
        )
        |> API.handle_response(val)
      end

      @doc """
      Update a(n) #{unquote(struct_name)}.

      Example
          result = conn |> ExNylas.#{__MODULE__}.#{unquote(config.name)}!(`id`, `body`, `params`)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, id, changeset, params) do
        case unquote(config.name)(conn, id, changeset, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(
         %{http_method: :post} = config,
         object,
         struct_name,
         header_type,
         use_admin_url
       ) do
    quote do
      @doc """
      Create a(n) #{unquote(struct_name)}.

      Example
          {:ok, result} = conn |> ExNylas.#{__MODULE__}.#{unquote(config.name)}(`body`, `params`)
      """
      def unquote(config.name)(%Conn{} = conn, body, params \\ %{}) do
        headers = apply(API, unquote(header_type), [conn]) ++ ["content-type": "application/json"]
        url = ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object))
        val = apply(unquote(struct_name), :as_struct, [])

        apply(
          API,
          unquote(config.http_method),
          [
            url,
            body,
            headers,
            [
              timeout: conn.timeout,
              recv_timeout: conn.recv_timeout,
              params: params
            ]
          ]
        )
        |> API.handle_response(val)
      end

      @doc """
      Create a(n) #{unquote(struct_name)}.

      Example
          result = conn |> ExNylas.#{__MODULE__}.#{unquote(config.name)}(`body`, `params`)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, body, params) do
        case unquote(config.name)(conn, body, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  def generate_url(conn, true = _use_admin_url, object) do
    "#{conn.api_server}/v3/#{object}"
  end

  def generate_url(conn, false = _use_admin_url, object) do
    "#{conn.api_server}/v3/grants/#{conn.grant_id}/#{object}"
  end

  defmacro __using__(opts) do
    quote do
      unquote(generate_funcs(opts))
    end
  end
end
