defmodule Whatsapp.Api.Contacts do
  @moduledoc """
  Módulo para el manejo de contactos de Whatsapp
  """

  @parser Application.get_env(:whatsapp_api, :parser)

  @doc """
  Valida la lista de teléfonos dada con el provider de Whatsapp
  """
  @spec check_list([String.t()], tuple(), boolean) :: map
  def check_list(phone_list, auth_header, wait \\ true) when is_list(phone_list) do
    _check_list(phone_list, auth_header, wait)
  end

  @doc """
  Valida un teléfono con el provider de Whatsapp
  """
  @spec check(String.t(), tuple(), boolean) :: boolean
  def check(phone, auth_header, wait \\ true) do
    _check_list([phone], auth_header, wait)
  end

  defp _check_list(phone_list, auth_header, wait) do
    blocking = (wait && "wait") || "no_wait"

    data = %{
      blocking: blocking,
      contacts: phone_list
    }

    "/contacts"
    |> WhatsappApiRequest.post!(data, [auth_header])
    |> @parser.parse(:contacts_check)
  end
end
