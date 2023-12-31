class KeysController < ApplicationController
  def error_head(status, message)
    Rails.logger.warn "#{status}: #{message}"
    render status:, json: { error: message }
  end

  def show
    return error_head(:unauthorized, 'missing authorization header') if token.nil?
    return error_head(:unauthorized, 'aud not matching') if token['aud'] != request.url

    if token['_oase_id'].nil?
      return error_head(:bad_request,
                        'missing oase or participant')
    end
    return error_head(:bad_request, 'oase_id not matching') if token['_oase_id'] != params[:oase_id]
    return error_head(:bad_request, 'key_id not matching') if token['sub'] != params[:key_id]
    return error_head(:bad_request, 'token expired') if token['exp'] < Time.now.to_i

    @key = if params[:key_id] == 'current'
             Key.current(oase_id: params[:oase_id], issuer: token['iss'])
           else
             Key.find_by(id: params[:key_id], oase_id: params[:oase_id], issuer: token['iss'])
           end

    return head :not_found if @key.nil?

    render json: {
      base64: @key.base64,
      kid: @key.id
    }
  end

  def create
    oase_id = params[:oase_id]
    issuer = params[:issuer]
    Key.generate(oase_id:, issuer:)
    head :created
  end

  private

  # Returns the decoded token which is assumed to have these claims:
  # sub: The the key id
  # _participant_id: The participation id of the token
  # _oase_id: The oase id of the token
  # iss: The issuer of the token (will most likely be https://api.oase.app)
  # aud: The audience of the token (must be https://kms.oase.app/[oase_id]/[key_id])
  # exp: The expiration date of the token
  # iat: The time the token was issued
  # jti: The unique identifier of the token
  def token
    @token ||= lambda do
      string = request.headers['Authorization'].split(' ').last
      payload = JSON::JWT.decode(string, :skip_verification)

      issuer = payload['iss']
      jwks = Rails.cache.fetch(issuer, expires_in: 12.hours) do
        Rails.logger.info "Fetching jwks for #{issuer}"
        jwks_url = "#{issuer}/.well-known/jwks.json"
        JSON.parse(HTTParty.get(jwks_url).body)
      end

      decoded_token = nil
      jwks['keys'].each do |jwk|
        break if decoded_token

        key = JSON::JWK.new(jwk).to_key
        begin
          decoded_token = JSON::JWT.decode string, key
        rescue StandardError
        end
      end

      decoded_token
    end.call
  end
end
