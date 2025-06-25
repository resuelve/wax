defmodule Mix.Tasks.SendMessage do
  @moduledoc """
  Send test messages

  Set the ENV variables DEV_NUMBER, DEV_WA_NUMBER_ID and DEV_SERVER_TOKEN
  with the correct values to be able to send messages.

  DEV_NUMBER: The number you want the message to be sent to
  DEV_WA_NUMBER_ID: The ID of the Whatsapp Cloud API number
  DEV_WA_TOKEN: The TOKEN the Whatsapp Phone Number requieres for Authentication


  An argument for the message type can be sent. Currently supported message types are:
  - text

  The default message type is `text`

  """
  @shortdoc "Echoes arguments"

  alias Wax.CloudAPI.{Auth, Messages}
  alias Wax.Messages.Message

  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run([]) do
    run(["text"])
  end

  def run([message_type | _]) do
    to_number = System.get_env("DEV_NUMBER")
    wa_number_id = System.get_env("DEV_WA_NUMBER_ID")
    token = System.get_env("DEV_WA_TOKEN")

    send_message(wa_number_id, to_number, message_type, token)
  end

  defp send_message(nil, _to_number, _message_type, _token),
    do: Mix.shell().error("DEV_WA_NUMBER_ID env variable is missing")

  defp send_message(_wa_number_id, nil, _message_type, _token),
    do: Mix.shell().error("DEV_NUMBER env variable is missing")

  defp send_message(_wa_number_id, _tot_number, _message_type, nil),
    do: Mix.shell().error("DEV_WA_TOKEN env variable is missing")

  defp send_message(wa_number_id, to_number, message_type, token) do
    auth = %Auth{whatsapp_number_id: wa_number_id, token: token}

    with %Message{} = message <- Message.new(to_number),
         %Message{} = message <- build_test_message(message, message_type),
         {:ok, _response} <- Messages.send(message, auth) do
      Mix.shell().info("Message sent correctly")
    else
      {:error, error} when is_binary(error) ->
        Mix.shell().error(error)
    end
  end

  @spec build_test_message(Message.t(), String.t()) :: Message.t()
  defp build_test_message(message, "text") do
    now = DateTime.to_iso8601(DateTime.utc_now())

    message
    |> Message.set_type(:text)
    |> Message.set_text("Text message test " <> now)
  end

  defp build_test_message(_message, message_type) do
    {:error, "Message type #{message_type} not supported"}
  end
end
