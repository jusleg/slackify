# frozen_string_literal: true

module SlackTokenVerify
  extend ActiveSupport::Concern

  included do
    before_action :verify_token
  end

  private

  MAX_TS_DIFF_SECONDS = 30.seconds

  def verify_token
    hmac_header = request.headers["X-Slack-Signature"]
    timestamp = request.headers["X-Slack-Request-Timestamp"]
    request_body = request.raw_post

    time_diff = (Time.now.to_i - timestamp.to_i).abs
    if time_diff > MAX_TS_DIFF_SECONDS
      message = "Slack webhook secret timestamp over time limit, limit is #{MAX_TS_DIFF_SECONDS}, "\
        "time difference is #{time_diff}"
      logger.warn(message)

      return head(:unauthorized)
    end

    signature = "v0:#{timestamp}:#{request_body}"
    calculated_hmac = "v0=" +
                      OpenSSL::HMAC.hexdigest("sha256", Slackify.configuration.slack_secret_token, signature)

    return if ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)

    message = "Invalid Slack signature received"
    logger.warn(message)

    head(:unauthorized)
  end
end
