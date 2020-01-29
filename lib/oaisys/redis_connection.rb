require 'nanoid'

class Oaisys::RedisConnection

  NANOID_TOKEN_ALPHABBET = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.freeze
  NANOID_TOKEN_SIZE = 22

  class ConnectionError < StandardError; end

  def initialize(redis_url: Oaisys::Engine.config.redis_url)
    @redis = Redis.new(url: redis_url)
    raise ConnectionError unless connected?
  end

  def create_token(parameters:, verb:, identifier:)
    raise ConnectionError unless connected?

    resumption_token = Nanoid.generate(size: NANOID_TOKEN_SIZE, alphabet: NANOID_TOKEN_ALPHABBET)
    redis_key = "oaisys.#{identifier}.#{verb}.#{resumption_token}"
    @redis.set redis_key, parameters.to_json
    @redis.expire(redis_key, 72.hours)
    resumption_token
  end

  def get_parameters(resumption_token:, verb:, identifier:)
    raise ConnectionError unless connected?

    redis_key = "oaisys.#{identifier}.#{verb}.#{resumption_token}"
    json_parameters = @redis.get(redis_key)
    return JSON.parse(json_parameters).symbolize_keys unless json_parameters.nil?

    nil
  end

  def expire_token(resumption_token:, verb:, identifier:)
    raise ConnectionError unless connected?

    redis_key = "oaisys.#{identifier}.#{verb}.#{resumption_token}"
    @redis.expire(redis_key, 0)
  end

  protected

  def connected?
    @redis.ping == 'PONG'
  end

end
