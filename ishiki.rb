#!/usr/bin/env ruby

require 'logger'
require 'twitterstream'
require_relative 'ishiki'

log = Logger.new(STDOUT)
STDOUT.sync = true

# REST API
rest = Twitter::Client.new(
  :consumer_key       => ENV['TWITTER_CONSUMER_KEY'],
  :consumer_secret    => ENV['TWITTER_CONSUMER_SECRET'],
  :oauth_token        => ENV['TWITTER_ACCESS_TOKEN'],
  :oauth_token_secret => ENV['TWITTER_ACCESS_TOKEN_SECRET'],
)

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
    friends   = rest.friend_ids.all
    followers = rest.follower_ids.all
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
        if.rest.unfollow(id)
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

    log.info('status @%s: %s' % [status.from_user, status.text])
    
  end
  
end




