defmodule ExNylas do

  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  @funcs %{
    list: %{name: :list, http_method: :get},
    first: %{name: :first, http_method: :get},
    search: %{name: :search, http_method: :get},
    find: %{name: :find, http_method: :get},
    delete: %{name: :delete, http_method: :delete},
    # Not all objects support both put and post
    # Thus need to differentiate using the update/create key here
    update: %{name: :save, http_method: :put},
    create: %{name: :save, http_method: :post},
    send: %{name: :send, http_method: :post},
  }

  defp generate_funcs(opts) do
    only = Keyword.get(opts, :only, Map.keys(@funcs))
    except = Keyword.get(opts, :except, [])
    object = Keyword.get(opts, :object)
    struct_name = Keyword.get(opts, :struct)
    header_type = Keyword.get(opts, :header_type, :header_bearer)
    use_client_url = Keyword.get(opts, :use_client_url, false)

    @funcs
    |> Map.keys()
    |> Enum.filter(&(&1 in only && &1 not in except))
    |> Enum.map(fn k ->
      Map.get(@funcs, k)
      |> generate_api(object, struct_name, header_type, use_client_url)
    end)
  end

  defp generate_api(%{http_method: :get, name: :first} = config, object, struct_name, header_type, use_client_url) do
    quote do
      def unquote(config.name)(%Conn{} = conn, params \\ %{}) do
        headers = apply(ExNylas.API, unquote(header_type), [conn])

        url =
          if unquote(use_client_url) do
            "#{conn.api_server}/a/#{conn.client_id}/#{unquote(object)}"
          else
            "#{conn.api_server}/#{unquote(object)}"
          end

        res =
          apply(
            ExNylas.API,
            unquote(config.http_method),
            [
              url,
              headers,
              [params: params]
            ]
          )

        case res do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            {:ok, List.first(body) |> TF.transform(unquote(struct_name))}

          {:ok, %HTTPoison.Response{body: body}} ->
            {:error, body}

          {:error, %HTTPoison.Error{reason: reason}} ->
            {:error, reason}
        end
      end

      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, params \\ %{}) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: :get, name: :search} = config, object, struct_name, header_type, use_client_url) do
    quote do
      def unquote(config.name)(%Conn{} = conn, search_text) do
        headers = apply(ExNylas.API, unquote(header_type), [conn])

        url =
          if unquote(use_client_url) do
            "#{conn.api_server}/a/#{conn.client_id}/#{unquote(object)}/search"
          else
            "#{conn.api_server}/#{unquote(object)}/search"
          end

        res =
          apply(
            ExNylas.API,
            unquote(config.http_method),
            [
              url,
              headers,
              [params: %{q: search_text}]
            ]
          )

        case res do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            {:ok, TF.transform(body, unquote(struct_name))}

          {:ok, %HTTPoison.Response{body: body}} ->
            {:error, body}

          {:error, %HTTPoison.Error{reason: reason}} ->
            {:error, reason}
        end
      end

      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, search_text) do
        case unquote(config.name)(conn, search_text) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: :get} = config, object, struct_name, header_type, use_client_url) do
    quote do
      def unquote(config.name)(%Conn{} = conn, params \\ %{}) do
        headers = apply(ExNylas.API, unquote(header_type), [conn])

        url =
          if unquote(use_client_url) do
            "#{conn.api_server}/a/#{conn.client_id}/#{unquote(object)}"
          else
            "#{conn.api_server}/#{unquote(object)}"
          end

        res =
          apply(
            ExNylas.API,
            unquote(config.http_method),
            [
              url,
              headers,
              [params: params]
            ]
          )

        case res do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            {:ok, TF.transform(body, unquote(struct_name))}

          {:ok, %HTTPoison.Response{body: body}} ->
            {:error, body}

          {:error, %HTTPoison.Error{reason: reason}} ->
            {:error, reason}
        end
      end

      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, params \\ %{}) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: method, name: name} = config, object, struct_name, header_type, use_client_url) when name in [:find, :delete] and method in [:get, :delete] do
    quote do
      def unquote(config.name)(%Conn{} = conn, id) do
        headers = apply(ExNylas.API, unquote(header_type), [conn])

        url =
          if unquote(use_client_url) do
            "#{conn.api_server}/a/#{conn.client_id}/#{unquote(object)}/#{id}"
          else
            "#{conn.api_server}/#{unquote(object)}/#{id}"
          end

        res =
          apply(
            ExNylas.API,
            unquote(method),
            [
              url,
              headers
            ]
          )

        case res do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            {:ok, TF.transform(body, unquote(struct_name))}

          {:ok, %HTTPoison.Response{body: body}} ->
            {:error, body}

          {:error, %HTTPoison.Error{reason: reason}} ->
            {:error, reason}
        end
      end

      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, id) do
        case unquote(config.name)(conn, id) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: :put} = config, object, struct_name, header_type, use_client_url) do
    quote do
      def unquote(config.name)(%Conn{} = conn, changeset, id) do
        headers = apply(ExNylas.Api, unquote(header_type), [conn])

        url =
          if unquote(use_client_url) do
            "#{conn.api_server}/a/#{conn.client_id}/#{unquote(object)}"
          else
            "#{conn.api_server}/#{unquote(object)}/#{id}"
          end

        res =
          apply(
            ExNylas.API,
            unquote(config.http_method),
            [
              url,
              headers,
              changeset
            ]
          )

        case res do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            {:ok, TF.transform(body, unquote(struct_name))}

          {:ok, %HTTPoison.Response{body: body}} ->
            {:error, body}

          {:error, %HTTPoison.Error{reason: reason}} ->
            {:error, reason}
        end
      end

      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, changeset, id) do
        case unquote(config.name)(conn, changeset, id) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: :post} = config, object, struct_name, header_type, use_client_url) do
    quote do
      def unquote(config.name)(%Conn{} = conn, body) do
        headers = apply(ExNylas.API, unquote(header_type), [conn])

        url =
          if unquote(use_client_url) do
            "#{conn.api_server}/a/#{conn.client_id}/#{unquote(object)}"
          else
            "#{conn.api_server}/#{unquote(object)}"
          end

        res =
          apply(
            ExNylas.API,
            unquote(config.http_method),
            [
              url,
              headers,
              body
            ]
          )

        case res do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            {:ok, TF.transform(body, unquote(struct_name))}

          {:ok, %HTTPoison.Response{body: body}} ->
            {:error, body}

          {:error, %HTTPoison.Error{reason: reason}} ->
            {:error, reason}
        end
      end

      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, body) do
        case unquote(config.name)(conn, body) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defmacro __using__(opts) do
    quote do
      unquote(generate_funcs(opts))
    end
  end

end
