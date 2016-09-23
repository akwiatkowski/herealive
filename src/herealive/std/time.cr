struct Time
  def to_json
    self.epoch_ms.to_json
  end
end
