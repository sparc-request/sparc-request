module SaveAndOpenScreenshot

  def sos
    save_and_open_screenshot
  end
end

RSpec.configure do |config|
  config.include SaveAndOpenScreenshot, type: :feature
end