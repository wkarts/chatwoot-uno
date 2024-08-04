class Whatsapp::OneoffUnoapiCampaignService
  pattr_initialize [:campaign!]

  def perform
    raise "Invalid campaign #{campaign.id}" if inbox.inbox_type != 'Whatsapp' || channel.provider != 'unoapi' || !campaign.one_off?
    raise 'Completed Campaign' if campaign.completed?

    # marks campaign completed so that other jobs won't pick it up
    campaign.completed!

    process_audience(campaign.audience)
  end

  private

  delegate :inbox, to: :campaign
  delegate :channel, to: :inbox

  def process_audience(audience)
    Rails.logger.debug { "Process campaign #{campaign.id} and #{audience.length} audience record(s)" }
    interval = 0.seconds
    new_audience = audience.map do |a|
      aa = update_audience(a)
      interval = schedule_job(campaign, aa, interval)
      aa
    end
    # rubocop:disable Rails/SkipsModelValidations
    campaign.update_column(:audience, new_audience)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def update_audience(audience)
    audience[:status] = 'scheduled'
    audience[:audience_id] = SecureRandom.uuid
    audience
  end

  def schedule_job(campaign, audience, interval)
    interval += rand(1..10).seconds
    CampaignMessageJob.set(wait_until: DateTime.current + interval.seconds).perform_later(
      campaign.account_id,
      campaign.inbox_id,
      campaign.id,
      campaign.message,
      audience.symbolize_keys
    )
    interval
  end
end
