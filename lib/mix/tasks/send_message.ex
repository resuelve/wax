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
  - document
  - image
  - interactive
  - template
  - video

  The default message type is `text`

  """
  @shortdoc "Echoes arguments"

  alias Wax.CloudAPI.{Auth, Messages}
  alias Wax.CloudAPI.Media, as: MediaManager
  alias Wax.Messages.{Interactive, Media, Message, Template}
  alias Wax.Messages.Interactive
  alias Wax.Messages.Interactive.Section

  use Mix.Task

  @media_message_types ~w(audio document image video)

  @requirements ["app.start"]

  @impl Mix.Task
  def run([]) do
    run(["text"])
  end

  def run([message_type]) when message_type in @media_message_types do
    Mix.shell().error("Missing file_path parameter.\nEx. mix send_message image test_file.png")
  end

  def run([message_type, file_path | _]) do
    if File.exists?(file_path) do
      params = %{file_path: file_path}
      do_run(message_type, params)
    else
      Mix.shell().error("File #{file_path} doesn't exist")
    end
  end

  def run([message_type | _]) do
    do_run(message_type)
  end

  defp do_run(message_type, params \\ %{}) do
    to_number = System.get_env("DEV_NUMBER")
    wa_number_id = System.get_env("DEV_WA_NUMBER_ID")
    token = System.get_env("DEV_WA_TOKEN")

    send_message(wa_number_id, to_number, message_type, token, params)
  end

  defp send_message(nil, _to_number, _message_type, _token, _params),
    do: Mix.shell().error("DEV_WA_NUMBER_ID env variable is missing")

  defp send_message(_wa_number_id, nil, _message_type, _token, _params),
    do: Mix.shell().error("DEV_NUMBER env variable is missing")

  defp send_message(_wa_number_id, _tot_number, _message_type, nil, _params),
    do: Mix.shell().error("DEV_WA_TOKEN env variable is missing")

  defp send_message(wa_number_id, to_number, message_type, token, params) do
    auth = %Auth{whatsapp_number_id: wa_number_id, token: token}

    with %Message{} = message <- Message.new(to_number),
         {:ok, params} <- upload_media_if_required(auth, params),
         %Message{} = message <- build_test_message(message, message_type, params),
         {:ok, _response} <- Messages.send(message, auth) do
      Mix.shell().info("Message sent correctly")
    else
      {:error, error} when is_binary(error) ->
        Mix.shell().error(error)
    end
  end

  # Adds media_id to params if a media upload was made
  @spec upload_media_if_required(Auth.t(), map()) ::
          {:ok, map()} | {:error, String.t()}
  defp upload_media_if_required(auth, %{file_path: file_path} = params) do
    case MediaManager.upload(file_path, auth) do
      {:ok, media_id} ->
        {:ok, Map.put(params, :media_id, media_id)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp upload_media_if_required(_auth, params) do
    {:ok, params}
  end

  @spec build_test_message(Message.t(), String.t(), map()) :: Message.t()
  defp build_test_message(message, "text", _params) do
    now = DateTime.to_iso8601(DateTime.utc_now())

    message
    |> Message.set_type(:text)
    |> Message.set_text("Text message test " <> now)
  end

  defp build_test_message(message, "audio", %{media_id: media_id}) do
    message
    |> Message.set_type(:audio)
    |> Message.add_audio(media_id)
  end

  defp build_test_message(message, "document", %{media_id: media_id, file_path: file_path}) do
    filename = Path.basename(file_path)

    message
    |> Message.set_type(:document)
    |> Message.add_document(media_id, filename, "This is a document caption")
  end

  defp build_test_message(message, "image", %{media_id: media_id}) do
    message
    |> Message.set_type(:image)
    |> Message.add_image(media_id, "This is a caption")
  end

  defp build_test_message(message, "interactive", _params) do
    interactive =
      Interactive.new()
      |> Interactive.put_header(:text, "Header", "Subtexto")
      |> Interactive.put_body("BODY")
      |> Interactive.put_footer("This is a footer")
      |> Interactive.put_button_action(["First Button", "Second Button"])

    message
    |> Message.set_type(:interactive)
    |> Message.add_interactive(interactive)
  end

  defp build_test_message(message, "interactive-list", _params) do
    section_1 =
      Section.new()
      |> Section.put_title("Section 1 Title")
      |> Section.add_row("row1", "Row 1 title", "This is a row with a description")
      |> Section.add_row("row2", "Row 2 title")

    section_2 =
      Section.new()
      |> Section.put_title("Section 2 Title")
      |> Section.add_row("s21", "Testing", "Description")

    interactive =
      Interactive.new()
      |> Interactive.put_header(:text, "Header", "Subtexto")
      |> Interactive.put_body("BODY")
      |> Interactive.put_footer("This is a footer")
      |> Interactive.put_list_action("A button?", [section_1, section_2])

    message
    |> Message.set_type(:interactive)
    |> Message.add_interactive(interactive)
  end

  defp build_test_message(message, "interactive-product", _params) do
    # You have to have a Catalog with products made on the Whatsapp Bussiness side

    interactive =
      Interactive.new()
      |> Interactive.put_body("BODY")
      |> Interactive.put_footer("This is a footer")
      |> Interactive.put_product_action("PRODUCT_ID", "bravo")

    message
    |> Message.set_type(:interactive)
    |> Message.add_interactive(interactive)
  end

  defp build_test_message(message, "interactive-flow", _params) do
    # You have to have a Flow created on the Whatsapp Bussiness side

    interactive =
      Interactive.new()
      |> Interactive.put_header(:text, "Header", "Subtexto")
      |> Interactive.put_body("BODY")
      |> Interactive.put_footer("This is a footer")
      |> Interactive.put_flow_action("CTA Button", {:name, "some-flow"})

    message
    |> Message.set_type(:interactive)
    |> Message.add_interactive(interactive)
  end

  defp build_test_message(message, "template", %{media_id: media_id}) do
    template_name = "test_url_and_image"
    language = "es_MX"

    header_params = [
      {:image, Media.new_image(media_id)}
    ]

    body_params = [
      {:text, "Mr. Test"}
    ]

    button_params = [
      {:text, "some_url_suffix"}
    ]

    template =
      template_name
      |> Template.new(language)
      |> Template.add_header(header_params)
      |> Template.add_body(body_params)
      |> Template.add_button(:url, 0, button_params)

    message
    |> Message.set_type(:template)
    |> Message.add_template(template)
  end

  defp build_test_message(message, "video", %{media_id: media_id}) do
    message
    |> Message.set_type(:video)
    |> Message.add_video(media_id, "This is a video caption")
  end

  defp build_test_message(_message, message_type, _params) do
    {:error, "Message type #{message_type} not supported"}
  end
end
