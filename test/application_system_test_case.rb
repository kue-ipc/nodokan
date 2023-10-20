require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  # driven_by :selenium, using: :headless_chrome, screen_size: [1024, 768] do |driver_option|
  #   driver_option.add_argument('no-sandbox')
  #   driver_option.add_argument('disable-gpu')
  #   driver_option.add_argument('disable-features=VizDisplayCompositor')
  # end
end
