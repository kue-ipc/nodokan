# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:rake"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.day, at: "23:00 pm" do
  rake "kea:check"
  rake "radius:check"
  rake "user:sync"
end

every 1.day, at: "1:00 am" do
  rake "radius:clean"
  rake "ipv4_arp:clean"
  rake "ipv6_neighbor:clean"
end

every 20.minutes, at: 10 do
  rake "ipv4_arp:register"
  rake "ipv6_neighbor:register"
end

every 1.hour do
  rake "nic:check"
end
