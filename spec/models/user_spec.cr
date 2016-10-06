require "../spec_helper"

describe User do
  it "works" do
    u = User.new
    puts u.estimated_arrival(lat: 0.0, lon: 0.0)
  end
end
