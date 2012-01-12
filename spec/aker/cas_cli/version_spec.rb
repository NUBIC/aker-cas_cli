require 'spec_helper'

module Aker
  describe CasCli, "::VERSION" do
    it "exists" do
      lambda { CasCli::VERSION }.should_not raise_error
    end

    it "has 3 or 4 dot separated parts" do
      CasCli::VERSION.split('.').size.should be_between(3, 4)
    end
  end
end
