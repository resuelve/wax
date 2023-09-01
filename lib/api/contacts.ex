defmodule Whatsapp.Api.Contacts do
  @moduledoc """
  Módulo para el manejo de contactos de Whatsapp
  """
  @parser Application.get_env(:wax, :parser)

  @doc """
  Valida la lista de teléfonos dada con el provider de Whatsapp
  """
  def check_list(_, _, _ \\ true)

  def check_list({:error, _} = error, _, _), do: error

  @spec check_list(tuple(), [String.t()], boolean) :: map
  def check_list(token_info, phone_list, wait) when is_list(phone_list) do
    _check_list(token_info, phone_list, wait)
  end

  @doc """
  Valida un teléfono con el provider de Whatsapp
  """
  def check(_, _, _ \\ true)
  def check({:error, _} = error, _, _), do: error

  @spec check(tuple(), String.t(), boolean) :: boolean
  def check(token_info, phone, wait) do
    _check_list(token_info, [phone], wait)
  end

  defp _check_list({url, auth_header}, phone_list, wait) do
    blocking = (wait && "wait") || "no_wait"

    data = %{
      blocking: blocking,
      contacts: phone_list
    }

    url
    |> Kernel.<>("/contacts")
    |> WhatsappApiRequest.rate_limit_request(:post!, data, [auth_header])
    |> @parser.parse(:contacts_check)
  end
end
