module WaitForBlock
  # blockの中身がtrueになるまで待つ
  # @param [Proc] block
  def wait_for_block(&block)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until block.call
    end
    yield if block_given?
  end
end

RSpec.configure do |config|
  config.include WaitForBlock, type: :system
end