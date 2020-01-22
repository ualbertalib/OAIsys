require 'nanoid'

class Oaisys::RedisConnection

  class ConnectionError < StandardError; end

  def initialize(redis_url: Oaisys::Engine.config.redis_url)
    @redis = Redis.new(url: redis_url)
    raise ConnectionError unless connected?
  end

  def create_token(parameters:, verb:, identifier:)
    raise ConnectionError unless connected?

    resumption_token = Nanoid.generate(size: 22,
                                       alphabet: '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
    redis_key = 'oaisys' + '.' + identifier + '.' + verb + '.' + resumption_token
    @redis.set redis_key, parameters.to_json
    # Set to expire in 72 hours.
    @redis.expire(redis_key, 259_200)
    resumption_token
  end

  def get_parameters(resumption_token:, verb:, identifier:)
    raise ConnectionError unless connected?

    redis_key = 'oaisys' + '.' + identifier + '.' + verb + '.' + resumption_token
    json_parameters = @redis.get(redis_key)
    return JSON.parse(json_parameters).symbolize_keys unless json_parameters.nil?

    nil
  end

  def expire_token(resumption_token:, verb:, identifier:)
    raise ConnectionError unless connected?

    redis_key = 'oaisys' + '.' + identifier + '.' + verb + '.' + resumption_token
    @redis.expire(redis_key, 0)
  end

  protected

  def connected?
    @redis.ping == 'PONG'
  end

end
