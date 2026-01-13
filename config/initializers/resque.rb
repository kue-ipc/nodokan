# resque

# TODO: issueの対応状況に応じて変更すること
# sinatra used by resque serevr, but dose not set permitted_hosts
# https://github.com/resque/resque/issues/1908

Rails.application.config.after_initialize do
  require "sinatra/base"
  class Sinatra::Base
    set :host_authorization, permitted_hosts: Rails.application.config.hosts.map(&:to_s)
  end
end
