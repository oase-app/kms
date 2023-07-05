class Key < ApplicationRecord
  def self.generate(oase_id:, issuer:)
    key = SecureRandom.random_bytes(32)
    create(
      oase_id:,
      issuer:,
      base64: Base64.strict_encode64(key)
    )
  end

  def self.current(oase_id:, issuer:)
    where(oase_id:, issuer:).order(created_at: :desc).first || generate(oase_id:, issuer:)
  end
end
