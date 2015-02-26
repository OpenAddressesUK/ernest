require 'spec_helper'

describe Confidence do
  
  it "must have a value" do
    # Valid
    c = Confidence.new(value: 0.85)
    expect(c.value).to eq 0.85
    expect(c.valid?).to eq true
    # Invalid
    c = Confidence.new
    expect(c.valid?).to eq false
  end

end