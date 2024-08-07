class NetworkDomain < NetworkOption
  def text=(value)
    self.data = value.to_s.to_json
  end
end
