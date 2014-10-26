#!/usr/bin/env ruby

require 'logger'
require 'tweetstream'
require 'ishiki'

include Ishiki

log = Logger.new(STDOUT)
STDOUT.sync = true

# REST
rest = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

# Stream API

TweetStream.configure do |config|
  config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  config.auth_method        = :oauth
end
stream = TweetStream::Client.new

EM.error_handler do |e|
  raise e.message
end

EM.run do
  # auto folllow and unfollow (every 5 minutes)
  EM.add_periodic_timer(300) do
    friends   = rest.friend_ids.attrs[:ids]
    followers = rest.follower_ids.attrs[:ids]
    to_follow = friends - followers
    to_unfollow = followers - friends
    # follow
    log.info('to follow: %s' % to_follow.inspect)
    to_follow.each do |id|
      log.info('follow %s' % id)
      begin
        if rest.follow(id)
          log.info('done.')
        end
      rescue => e
        log.error(e)
      end
    end
    #unfollow
    log.info('to unfollow: %s', to_unfollow.inspect)
    to_unfollow.each do |id|
      log.info('unfollow %s' % id)
      begin
        if rest.unfollow(id)
          log.info('done.')
        end
      end
    end
  end

  stream.on_inited do
    log.info('init')
  end
  
  stream.userstream do |status|
    next if status.retweet?
    next if status.reply?
    if high_level?(status.text)
      log.info('status @%s: %s' % [status.user.screen_name, status.text])
      EM.add_timer(rand(5) + 5) do
        begin
          tweet = rest.favorite(status.id)    
        rescue => e
          log.error(e)
        end
      end    
    end

  end
  
end




