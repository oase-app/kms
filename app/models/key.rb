class Key < ApplicationRecord
  def self.generate(oase_id:)
    create(
      oase_id:,
      value: SecureRandom.uuid
    )
  end

  def self.current(oase_id:)
    where(oase_id:).order(created_at: :desc).first || generate(oase_id:)
  end
end
