class HTMLMeta
  attr_accessor :title,:description,:image_url,:twitter_card

  def initialize(title: nil,description: nil,image_url: nil,twitter_card: nil)
    self.title =title
    self.description =description
    self.image_url =image_url
    self.twitter_card =twitter_card
  end
end
