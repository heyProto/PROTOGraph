class CsvVerificationWorker
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(upload_id)
    @upload = Upload.find(upload_id)
    require 'csv'
    # The last jq filter returns an array of json objects
    card_array_filtered = %x(csv2json #{@upload.attachment.file.file} | jq -f jq_filter.jq | jq -s '.')
    card_array_filtered = JSON.parse(card_array_filtered)
    schema = JSON.parse(RestClient.get(@upload.template_card.template_datum.schema_json))
    # url = "#{AWS_API_DATACAST_URL}/pub/validate-json"
    card_array_filtered.each do |card_filtered|
      CardUploadWorker.perform_async(@upload.id, card_filtered, "name", "seo_blockquote_text", "source")
    end
  end
end
